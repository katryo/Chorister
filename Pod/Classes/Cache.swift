import Foundation

public enum CacheExpiry {
    case Never
    case Seconds(NSTimeInterval)
    case Date(NSDate)
}

public class Cache<T: NSCoding> {
    public let name: String
    public let cacheDirectory: String
    
    private let cache = NSCache()
    private let fileManager = NSFileManager()
    private let diskQueue: dispatch_queue_t = dispatch_queue_create("com.katryo.cache.diskQueue", DISPATCH_QUEUE_SERIAL)
    
    public init(name: String, directory: String?) {
        self.name = name
        cache.name = name
        
        if let d = directory {
            cacheDirectory = d
        } else {
            let dir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first as String!
            cacheDirectory = dir.stringByAppendingFormat("/com.katryo.cache/%@", name)
        }
        
        if !fileManager.fileExistsAtPath(cacheDirectory) {
            do {
                try fileManager.createDirectoryAtPath(cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
    }
    
    public convenience init(name: String) {
        self.init(name: name, directory: nil)
    }
    
    public func setObjectForKey(key: String, cacheBlock: ((T, CacheExpiry) -> (), (NSError?) -> ()) -> (), completion: (T?, Bool, NSError?) -> ()) {
        if let object = objectForKey(key) {
            completion(object, true,nil)
        } else {
            let successBlock: (T, CacheExpiry) -> () = { (obj, expires) in
                self.setObject(obj, forKey: key, expires: expires)
                completion(obj, false, nil)
            }
            let failureBlock: (NSError?) -> () = { (error) in
                completion(nil, false, error)
            }
            cacheBlock(successBlock, failureBlock)
        }
    }
    
    public func objectForKey(key: String) -> T? {
        var possibleObject = cache.objectForKey(key) as? CacheObject
        
        if possibleObject == nil {
            dispatch_sync(diskQueue) {
                let path = self.pathForKey(key)
                if self.fileManager.fileExistsAtPath(path) {
                    possibleObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? CacheObject
                }
            }
        }
        
        if let object = possibleObject {
            if !object.isExpired() {
                return object.value as? T
            } else {
                removeObjectForKey(key)
            }
        }
        
        return nil
    }
    
    public func setObject(object: T, forKey key: String) {
        self.setObject(object, forKey: key, expires: .Never)
    }
    
    public func setObject(object: T, forKey key: String, expires: CacheExpiry) {
        let expiryDate = expiryDateForCacheExpiry(expires)
        let cacheObject = CacheObject(value: object, expiryDate: expiryDate)
        cache.setObject(cacheObject, forKey: key)
        
        dispatch_async(diskQueue) {
            let path = self.pathForKey(key)
            NSKeyedArchiver.archiveRootObject(cacheObject, toFile: path)
        }
    }
    
    public func removeObjectForKey(key: String) {
        cache.removeObjectForKey(key)
        
        dispatch_async(diskQueue) {
            let path = self.pathForKey(key)
            do {
                try self.fileManager.removeItemAtPath(path)
            } catch _ {
            }
        }
    }
    
    public func removeAllObjects() {
        dispatch_async(diskQueue) {
            self.cache.removeAllObjects()
            let paths = (try! self.fileManager.contentsOfDirectoryAtPath(self.cacheDirectory))
            for key in paths {
                let path = self.pathForKey(key)
                print("removing object in cache")
                do {
                    try self.fileManager.removeItemAtPath(path)
                } catch _ {
                }
            }
        }
    }
    
    public func removeExpiredObjects() {
        dispatch_async(diskQueue) {
            let paths = (try! self.fileManager.contentsOfDirectoryAtPath(self.cacheDirectory))
            let keys = paths.map { NSURL(fileURLWithPath: $0).URLByDeletingPathExtension?.absoluteString }
            
            for key in keys {
                
                // `objectForKey:` deletes the object if it is expired
                self.objectForKey(key!)
            }
        }
    }
    
    
    // MARK: Subscripting
    
    public subscript(key: String) -> T? {
        get {
            return objectForKey(escapeSlashes(key))
        }
        set(newValue) {
            if let value = newValue {
                setObject(value, forKey: escapeSlashes(key))
            } else {
                removeObjectForKey(escapeSlashes(key))
            }
        }
    }
    
    func pathForKey(key: String) -> String {
        let directoryURL = NSURL(string: cacheDirectory)
        let escapedKey = escapeSlashes(key)
        let pathURL = directoryURL!.URLByAppendingPathComponent(escapedKey)
        return pathURL.absoluteString
    }
    
    private func expiryDateForCacheExpiry(expiry: CacheExpiry) -> NSDate {
        switch expiry {
        case .Never:
            return NSDate.distantFuture()
        case .Seconds(let seconds):
            return NSDate().dateByAddingTimeInterval(seconds)
        case .Date(let date):
            return date
        }
    }
    
    private func escapeSlashes(key: String) -> String {
        return key.stringByReplacingOccurrencesOfString("/", withString: "\\", options: [], range: nil)
    }
    
}