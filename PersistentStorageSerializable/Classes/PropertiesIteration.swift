//
//  PropertiesIteration.swift
//  Pods
//
//  Created by Ivan Rublev on 4/7/17.
//
//

import Foundation
import Reflection

let persistentStorageSerializableProtocolVariableNames: Set<String> = ["persistentStorage", "persistentStorageKeyPrefix"]

extension PersistentStorageSerializable {
    func selfPropertiesNames() throws -> [String] {
        let skipNames = persistentStorageSerializableProtocolVariableNames
        let propertiesDescription = try properties(Self.self)
        let keys: [String] = propertiesDescription.flatMap {
            skipNames.contains($0.key) ? nil : $0.key
        }
        return keys
    }
    
    /// Performs a closure over each of type instance's properties.
    ///
    /// - Parameter names: Set of properties names to skip during enumeration.
    /// - Parameter perform: Closure to be called on each property key and value pair.
    /// - Throws: Error from perform closure.
    func eachSelfProperty(perform: (_ key: String, _ value: Any) throws -> ()) throws {
        let keys: [String] = try selfPropertiesNames()
        
        var keyedValues = [String : Any]()
        var kvcSuccseed = false
        if let objcObj = self as? NSObject {
            SwiftTryCatch.try({
                keyedValues = objcObj.dictionaryWithValues(forKeys: keys)
                kvcSuccseed = true
            }, catch: nil, finallyBlock: nil)
        }
        if kvcSuccseed == false { // pure Swift object
            for aKey in keys {
                let propertyValue: Any? = try Reflection.get(aKey, from: self)
                guard let value = propertyValue
                    else {
                        throw PersistentStorageSerializableError.FailedToGetIntancePropertyValueForName(aKey)
                }
                keyedValues[aKey] = value
            }
        }
        
        for (key, value) in keyedValues {
            try perform(key, value)
        }
    }
    
    /// Sets a value for each property of type instance.
    ///
    /// - Parameter valueFor: Closure that returns value for specified property name. If returns nil then property is left untouched.
    /// - Throws: Error from valueFor closure.
    mutating func setEachSelfProperty(with valueFor: (_ propertyName: String) throws -> Any?) throws {
        let keys: [String] = try selfPropertiesNames()
        
        var keyedValues = [String : Any]()
        for aKey in keys {
            if let value = try valueFor(aKey) {
                keyedValues[aKey] = value
            }
        }

        var kvcSuccseed = false
        if let objcObj = self as? NSObject {
            SwiftTryCatch.try({
                objcObj.setValuesForKeys(keyedValues)
                kvcSuccseed = true
            }, catch: nil, finallyBlock: nil)
        }
        if kvcSuccseed == false { // pure Swift object
            for (key, value) in keyedValues {
                try Reflection.set(value, key: key, for: &self)
            }
            
        }
    }
}
