//
//  SupportedSerializableType.swift
//  Pods
//
//  Created by Ivan Rublev on 4/10/17.
//
//

import Foundation

public indirect enum PersistentStorageSerializableTypeError: Error {
    case UnsupportedOptional
    case NonPlistType
    case CollectionElement(PersistentStorageSerializableTypeError)
}

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
    
    @discardableResult static func serializable(value: Any) throws -> Bool {
        if value is OptionalProtocol { // we do not support optionals
            throw PersistentStorageSerializableTypeError.UnsupportedOptional
        }
        if isSerializableType(value: value) {
            return true
        } // else not a simple type
        
        func areElementsOfSerializableType<T: Sequence>(for sequence: T) throws -> Bool {
            for element in sequence {
                do {
                    try serializable(value: element)
                }
                catch let error as PersistentStorageSerializableTypeError {
                    throw PersistentStorageSerializableTypeError.CollectionElement(error)
                }
            }
            return true
        }
        
        if value is ArrayProtocol, let abstractArray = value as? Array<Any> {
            return try areElementsOfSerializableType(for: abstractArray)
        }
        else if value is DictionaryProtocol, let abstractDictionary = value as? Dictionary<String, Any> {
            return try areElementsOfSerializableType(for: abstractDictionary.values)
        }
        // else is not of required collection type
        throw PersistentStorageSerializableTypeError.NonPlistType
    }
    
}
