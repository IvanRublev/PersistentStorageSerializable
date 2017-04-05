//
//  PersistentStorage.swift
//  Pods
//
//  Created by Ivan Rublev on 4/5/17.
//
//

import Foundation

/**
    Abstract protocol to read/write from persistent system storage.
 */
public protocol PersistentStorage: class {
    /// Begins sequence of operations with persistent storage. 
    func beginTransaction() throws
    
    /// Registers default values with storage. Like register(defaults:) method of UserDefaults.
    ///
    /// - Parameter defaultValues: Dictionary with defaults value.
    func register(defaultValues: [String : Any])
    
    /// Returns a value from persistent storage for specified key.
    ///
    /// - Parameter key: Key to read
    /// - Returns: Value from the persistent storage or nil if there is no value for the specified key.
    func get(valueOf key: String) -> Any?
    
    /// Sets a value for specified key into persistent storage.
    /// When value is nil then the key/value pair is removed from the storage.
    /// Call synchronize() after all key/value pairs are set to commit changes to the storage.
    ///
    /// - Parameters:
    ///   - value: Value to store
    ///   - key: Key
    /// - Throws: Storage write error.
    func set(value: Any?, for key: String) throws
    
    /// Commits operations to the persistent storage.
    func finishTransaction() throws
}
