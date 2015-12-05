import Foundation

class CacheObject: NSObject, NSCoding {
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
        value = aDecoder.decodeObjectForKey("value") as AnyObject!
        expiryDate = aDecoder.decodeObjectForKey("expiryDate") as! NSDate
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value, forKey: "value")
        aCoder.encodeObject(expiryDate, forKey: "expiryDate")
    }
}