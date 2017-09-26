//
//  UserDefaultsStorage.swift
//  Pods
//
//  Created by Ivan Rublev on 4/5/17.
//
//

import Foundation

/**
    Interface protocol to UserDefaults object
 */
public protocol UserDefaultsStorageSystemUserDefaults {
    static var standard: UserDefaults { get }
    func register(defaults registrationDictionary: [String : Any])
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
    func synchronize() -> Bool
}

extension UserDefaults: UserDefaultsStorageSystemUserDefaults {}

/**
    Class to persist data in User Defaults storage.
 */
open class UserDefaultsStorage {
    /// Shared defaults storage
    open static let standard: PersistentStorage = UserDefaultsStorage()
    /// Bridge to defaults object
    var defaults: UserDefaultsStorageSystemUserDefaults {
        return UserDefaults.standard
    }
}

// MARK: - Adopt PersistentStorage
extension UserDefaultsStorage: PersistentStorage {
    open func beginTransaction() throws {
        precondition(Thread.isMainThread)
        let _ = defaults.synchronize()
    }
    
    open func register(defaultValues: [String : Any]) {
        precondition(Thread.isMainThread)
        defaults.register(defaults: defaultValues)
    }
    
    open func get(valueOf key: String) -> Any? {
        precondition(Thread.isMainThread)
        return defaults.object(forKey: key)
    }
    
    open func set(value: Any?, for key: String) throws {
        precondition(Thread.isMainThread)
        if let value = value {
            defaults.set(value, forKey: key)
        }
        else {
            defaults.removeObject(forKey: key)
        }
    }
    
    open func finishTransaction() throws {
        precondition(Thread.isMainThread)
        let _ = defaults.synchronize()
    }
}
