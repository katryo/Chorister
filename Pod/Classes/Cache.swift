import Foundation

public enum CacheExpiry {
    case Never
    case Seconds(TimeInterval)
    case Date(NSDate)
}

class Cache<T: NSCoding> {
    let name: String
    let cacheDirectory: String
    
    private let cache = NSCache<AnyObject, AnyObject>()
    private let fileManager = FileManager()
    private let diskQueue: DispatchQueue = DispatchQueue(label: "com.katryo.cache.diskQueue")
    
    init(name: String, directory: String?) {
        self.name = name
        cache.name = name
        
        if let d = directory {
            cacheDirectory = d
        } else {
            let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
            cacheDirectory = dir!.appendingFormat("/com.katryo.cache/%@", name)
        }
        
        if !fileManager.fileExists(atPath: cacheDirectory) {
            do {
                try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
    }
    
    convenience init(name: String) {
        self.init(name: name, directory: nil)
    }
    
    func setObjectForKey(key: String, cacheBlock: ((T, CacheExpiry) -> (), (NSError?) -> ()) -> (), completion: @escaping (T?, Bool, NSError?) -> ()) {
        if let object = objectForKey(key: key) {
            completion(object, true,nil)
        } else {
            let successBlock: (T, CacheExpiry) -> () = { (obj, expires) in
                self.setObject(object: obj, forKey: key, expires: expires)
                completion(obj, false, nil)
            }
            let failureBlock: (NSError?) -> () = { (error) in
                completion(nil, false, error)
            }
            cacheBlock(successBlock, failureBlock)
        }
    }
    
    func objectForKey(key: String) -> T? {
        var possibleObject = cache.object(forKey: key as AnyObject) as? CacheObject
        
        if possibleObject == nil {
            diskQueue.sync() {
                let path = self.pathForKey(key: key)
                if self.fileManager.fileExists(atPath: path) {
                    possibleObject = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? CacheObject
                }
            }
        }
        
        if let object = possibleObject {
            if !object.isExpired() {
                return object.value as? T
            } else {
                removeObjectForKey(key: key)
            }
        }
        
        return nil
    }
    
    func setObject(object: T, forKey key: String) {
        self.setObject(object: object, forKey: key, expires: .Never)
    }
    
    func setObject(object: T, forKey key: String, expires: CacheExpiry) {
        let expiryDate = expiryDateForCacheExpiry(expiry: expires)
        let cacheObject = CacheObject(value: object, expiryDate: expiryDate)
        cache.setObject(cacheObject, forKey: key as AnyObject)
        
        diskQueue.async() {
            let path = self.pathForKey(key: key)
            NSKeyedArchiver.archiveRootObject(cacheObject, toFile: path)
        }
    }
    
    func removeObjectForKey(key: String) {
        cache.removeObject(forKey: key as AnyObject)
        
        diskQueue.async() {
            let path = self.pathForKey(key: key)
            do {
                try self.fileManager.removeItem(atPath: path)
            } catch _ {
            }
        }
    }
    
    func removeAllObjects() {
        diskQueue.async() {
            self.cache.removeAllObjects()
            let paths = (try! self.fileManager.contentsOfDirectory(atPath: self.cacheDirectory))
            for key in paths {
                let path = self.pathForKey(key: key)
                print("removing object in cache")
                do {
                    try self.fileManager.removeItem(atPath: path)
                } catch _ {
                }
            }
        }
    }
    
    func removeExpiredObjects() {
        diskQueue.async() {
            let paths = (try! self.fileManager.contentsOfDirectory(atPath: self.cacheDirectory))
            let keys = paths.map { NSURL(fileURLWithPath: $0).deletingPathExtension?.absoluteString }
            
            for key in keys {
                
                let object = self.cache.object(forKey: key as AnyObject) as? CacheObject
                if object!.isExpired() {
                    self.removeObjectForKey(key: key!)
                }
            }
        }
    }
    
    
    // MARK: Subscripting
    
    subscript(key: String) -> T? {
        get {
            return objectForKey(key: escapeSlashes(key: key))
        }
        set(newValue) {
            if let value = newValue {
                setObject(object: value, forKey: escapeSlashes(key: key))
            } else {
                removeObjectForKey(key: escapeSlashes(key: key))
            }
        }
    }
    
    func pathForKey(key: String) -> String {
        let directoryURL = NSURL(string: cacheDirectory)
        let escapedKey = escapeSlashes(key: key)
        let pathURL = directoryURL!.appendingPathComponent(escapedKey)
        return pathURL!.absoluteString
    }
    
    private func expiryDateForCacheExpiry(expiry: CacheExpiry) -> NSDate {
        switch expiry {
        case .Never:
            return NSDate.distantFuture as NSDate
        case .Seconds(let seconds):
            return NSDate().addingTimeInterval(seconds)
        case .Date(let date):
            return date
        }
    }
    
    private func escapeSlashes(key: String) -> String {
        return key.replacingOccurrences(of: "/", with: "slash", options: [], range: nil)
    }
    
}
