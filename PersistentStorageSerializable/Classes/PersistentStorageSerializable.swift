//
//  PersistentStorageSerializable.swift
//  Pods
//
//  Created by Ivan Rublev on 4/5/17.
//
//

import Foundation
import Reflection

public enum PersistentStorageSerializableError: Error {
    case UnsupportedValueTypeForKey(String)
    case FailedToGetIntancePropertyValueForName(String)
}

/**
    Protocol for serialization of type with persistent storage.
 */
public protocol PersistentStorageSerializable {
    /// Storage type to serialize with
    var persistentStorage: PersistentStorage! { get set }
    /// Prefix that will be used to make a key for every type's property value in persistant storage
    var persistentStorageKeyPrefix: String! { get set }
    
    /// Values set in default initializer are registered as defaults with persistent storage.
    init()
    
    init(from persistentStorage: PersistentStorage, keyPrefix: String?) throws
    
    // MARK: Optional
    
    /// Returns a key to be used in persistent storage to keep type instance property value.
    /// Default implementation constructs the key by using persistentStorageKeyPrefix.
    ///
    /// - Parameter propertyName: Name of instanse property.
    /// - Returns: Key for instance property value in persistance storage.
    func persistentStorageKey(for propertyName: String) -> String
}

public extension PersistentStorageSerializable {
    /// Initializer calls default initializer then pulls properties values from persistent storage.
    ///
    /// - Parameters:
    ///   - persistentStorage: Persistent storage to serialize with.
    ///   - keyPrefix: Prefix for properties values key in persistent storage. If is not specified, then default value must be set in adopter type definition, or the `persistentStorageKey(for:)` function must be overloaded.
    /// - Throws: Error of pulling from storage.
    init(from persistentStorage: PersistentStorage, keyPrefix: String? = nil) throws {
        self.init()
        self.persistentStorage = persistentStorage
        if let keyPrefix = keyPrefix {
            self.persistentStorageKeyPrefix = keyPrefix
        }
        try pullFromPersistentStorage()
    }
    
    /// Read all type instance properties (skipping declared in the protocol) values from the persistent storage.
    /// If there is no value for a property in the persistent storage then keeps the instance's current property value.
    ///
    /// - Throws: Type instance property value setting error.
    public mutating func pullFromPersistentStorage() throws {
        try self.persistentStorage.beginTransaction()
        try registerInstancePropertiesValueAsDefaultsWithStorageOnce()
        try setEachSelfProperty { (key) -> Any? in
            let storageKey = self.persistentStorageKey(for: key)
            return self.persistentStorage.get(valueOf: storageKey)
        }
        try self.persistentStorage.finishTransaction()
    }
    
    /// Implementation of persist()
    public func pushToPersistentStorage() throws {
        try self.persistentStorage.beginTransaction()
        try registerInstancePropertiesValueAsDefaultsWithStorageOnce()
        try eachSelfProperty { (key, value) in
            let storageKey = self.persistentStorageKey(for: key)
            if Self.serializable(value: value) == false {
                throw PersistentStorageSerializableError.UnsupportedValueTypeForKey(key)
            }
            try self.persistentStorage.set(value: value, for: storageKey)
        }
        try self.persistentStorage.finishTransaction()
    }
    
    /// Writes all type instance properties (skipping declared in the protocol) values to the persistent storage.
    /// If instance's property value is nil then removes the value from the persistent storage.
    ///
    /// - Throws: Type instance property value reading error. Persistent storage write error.
    public func persist() throws {
        try pushToPersistentStorage()
    }
    
    /// Removes data from persistent storage if was previosly there.
    /// Uses current type properties names to search for values to remove.
    ///
    /// - Throws: Type properties description read error.
    public func removeFromPersistentStorage() throws {
        let allKeys = try persistedDictionaryRepresentation().keys
        try self.persistentStorage.beginTransaction()
        for key in allKeys {
            try self.persistentStorage.set(value: nil, for: key)
        }
        try self.persistentStorage.finishTransaction()
    }
    
    /// Returns dictionary representation of the persisted data for the type.
    /// Uses current type properties names to get persisted data from the storage.
    ///
    /// - Returns: Dictionary with data.
    /// - Throws: Type properties description read error.
    public func persistedDictionaryRepresentation() throws -> [String : Any] {
        var dictionary = [String : Any]()
        try self.persistentStorage.beginTransaction()
        let propertiesDescription = try properties(Self.self)
        for desc in propertiesDescription {
            let key = desc.key
            let storageKey = self.persistentStorageKey(for: key)
            if let value = self.persistentStorage.get(valueOf: storageKey) {
                dictionary[storageKey] = value
            }
        }
        try self.persistentStorage.finishTransaction()
        return dictionary
    }
    
    /// Default implementation
    public func persistentStorageKey(for propertyName: String) -> String {
        return String(format: "%@.%@", self.persistentStorageKeyPrefix, propertyName)
    }

}

// MARK: - Defaults registration with storage
var persistentStorageDefaultsRegistrationTracker = [String]()

extension PersistentStorageSerializable {
    /// Registers the current instance properties values as default values with storage once per app run.
    func registerInstancePropertiesValueAsDefaultsWithStorageOnce() throws {
        if persistentStorageDefaultsRegistrationTracker.contains(self.persistentStorageKeyPrefix) == false {
            persistentStorageDefaultsRegistrationTracker.append(self.persistentStorageKeyPrefix)
            
            var initialValueDictionary = [String : Any]()
            try eachSelfProperty { (key, value) in
                let storageKey = self.persistentStorageKey(for: key)
                initialValueDictionary[storageKey] = value
            }
            self.persistentStorage.register(defaultValues: initialValueDictionary)
        }
    }
}

// MARK: - Check for serializable type
protocol OptionalProtocol {}
extension Optional: OptionalProtocol {}

protocol ArrayProtocol {}
extension Array: ArrayProtocol {}

protocol DictionaryProtocol {}
extension Dictionary: DictionaryProtocol {}

extension PersistentStorageSerializable {
    static func isSerializableType(value: Any) -> Bool {
        return value is Data ||
            value is String ||
            value is UInt ||
            value is Int ||
            value is Float ||
            value is Double ||
            value is Bool ||
            value is URL ||
            value is Date
    }
    
    static func serializable(value: Any) -> Bool {
        if value is OptionalProtocol { // we do not support optionals
            return false
        }
        if isSerializableType(value: value) {
            return true
        } // else not a simple type
        
        func areElementsOfSerializableType<T: Sequence>(for sequence: T) -> Bool {
            for element in sequence {
                if (serializable(value: element)) == false {
                    return false
                }
            }
            return true
        }
        
        if value is ArrayProtocol, let abstractArray = value as? Array<Any> {
            return areElementsOfSerializableType(for: abstractArray)
        }
        else if value is DictionaryProtocol, let abstractDictionary = value as? Dictionary<String, Any> {
            return areElementsOfSerializableType(for: abstractDictionary.values)
        }
        // else is not of required collection type
        return false
    }
    
}
