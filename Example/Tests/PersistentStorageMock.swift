//
//  PersistentStorageMock.swift
//  PersistentStorageSerializable
//
//  Created by Ivan Rublev on 4/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import PersistentStorageSerializable

class PersistentStorageMock: PersistentStorage {
    var transactionWasBegan = false
    
    func beginTransaction() throws {
        transactionWasBegan = true
    }
    
    open static let shared: PersistentStorage = PersistentStorageMock()

    var registeredDefaultValues: [String : Any]?
    
    func register(defaultValues: [String : Any]) {
        registeredDefaultValues = defaultValues
    }

    typealias ValuesDictionary = Dictionary<String, Any>
    var tempValues = ValuesDictionary()
    var values = ValuesDictionary()
    
    public func get(valueOf key: String) -> Any? {
        if let value = tempValues[key] {
            return value
        }
        return values[key]
    }
    
    enum InternalError: Error {
        case Failure
    }
    var throwOnSet: InternalError?
    
    func set(value: Any?, for key: String) throws {
        if let errorToThrow = throwOnSet {
            throw errorToThrow
        }
        tempValues[key] = value
    }
    
    var synchronizeWasCalled = false
    
    func finishTransaction() throws {
        values = tempValues
        tempValues.removeAll()
        synchronizeWasCalled = true
    }
}
