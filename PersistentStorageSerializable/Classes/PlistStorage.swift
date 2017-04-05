//
//  PlistStorage.swift
//  Pods
//
//  Created by Ivan Rublev on 4/7/17.
//
//

import Foundation

/**
    Class to persist data in Plist file on disk.
 */
open class PlistStorage {
    let url: URL
    
    public init(at url: URL) {
        precondition(url.isFileURL)
        self.url = url
    }
    
    var dictionary: NSMutableDictionary?
    var newDictionary: NSMutableDictionary!
    
    var anyKeyWasSet = false
    var finished = true
}

// MARK: - Adopt PersistentStorage
extension PlistStorage: PersistentStorage {
    public func beginTransaction() throws {
        precondition(finished, "Must call finishTransaction() before beginning a new one.")
        finished = false
        SwiftTryCatch.try({ 
            self.dictionary = NSMutableDictionary(contentsOf: self.url)
        }, catch: nil, finallyBlock: nil)
        newDictionary = NSMutableDictionary()
    }
    
    public func register(defaultValues: [String : Any]) { // default values are not applicable
    }
    
    public func get(valueOf key: String) -> Any? {
        return dictionary?[key]
    }

    public func set(value: Any?, for key: String) throws {
        newDictionary[key] = value
        anyKeyWasSet = true
    }

    public func finishTransaction() throws {
        dictionary = nil
        if anyKeyWasSet {
            let data = try PropertyListSerialization.data(fromPropertyList: newDictionary, format: .xml, options: 0)
            try data.write(to: url, options: .atomic)
        }
        anyKeyWasSet = false
        newDictionary = nil
        finished = true
    }
}
