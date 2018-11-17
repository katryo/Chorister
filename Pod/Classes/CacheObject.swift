import Foundation

class CacheObject: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
        aCoder.encode(expiryDate, forKey: "expiryDate")
    }
    
    let value: AnyObject
    let expiryDate: NSDate
    
    init(value: AnyObject, expiryDate: NSDate) {
        self.value = value
        self.expiryDate = expiryDate
    }
    
    func isExpired() -> Bool {
        let expires = expiryDate.timeIntervalSinceNow
        let now = NSDate().timeIntervalSinceNow
        
        return now > expires
    }
    
    required init?(coder aDecoder: NSCoder) {
        value = aDecoder.decodeObject(forKey: "value") as AnyObject
        expiryDate = aDecoder.decodeObject(forKey: "expiryDate") as! NSDate
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
        aCoder.encode(expiryDate, forKey: "expiryDate")
    }
}
