//
//  SlashAcceptableCache.swift
//  DenkinovelPrototypeTwo
//
//  Created by RYOKATO on 2015/12/05.
//  Copyright © 2015年 Denkinovel. All rights reserved.
//

import Foundation
import AwesomeCache

struct SlashAcceptableCache {
    internal let body: Cache<NSData>
    
    init(cache: Cache<NSData>) {
        self.body = cache
    }
    
    func objectForKey(key: String) -> NSData? {
        let escapedKey = escapeSlashes(key)
        return self.body.objectForKey(escapedKey)
    }
    
    func setObjectForKey(object: NSData, key: String) {
        let escapedKey = escapeSlashes(key)
        self.body.setObject(object, forKey: escapedKey)
    }
    
    func pathForKey(key: String) -> String {
        let directoryURL = body.cacheDirectory
        let escapedKey = escapeSlashes(key)
        let pathURL = directoryURL.URLByAppendingPathComponent(escapedKey)
        return pathURL.absoluteString
    }
    
    func removeAllObjects() {
        body.removeAllObjects()
    }
    
    private func escapeSlashes(key: String) -> String {
        return key.stringByReplacingOccurrencesOfString("/", withString: "\\", options: [], range: nil)
    }
    
}