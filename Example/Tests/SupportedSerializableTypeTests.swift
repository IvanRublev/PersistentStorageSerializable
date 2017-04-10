
//
//  PersistentStorageSerializableTypeTests.swift
//  PersistentStorageSerializable
//
//  Created by Ivan Rublev on 4/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import PersistentStorageSerializable

class PersistentStorageSerializableTypesTests: QuickSpec {
    override func spec() {
        describe("Properties value of") {
            context("supported types") {
                let someData: Data = "Hello".data(using: String.Encoding.utf8)!
                let someDate: Date = Date(timeIntervalSinceReferenceDate: 1)
                let arrayOfUrl = [URL(string: "https://some.web")!, URL(string: "https://otherweb.com")!]
                it("serializable.") {
                    expect { try Person.serializable(value: someData as Any) }.toNot(throwError())
                    expect { try Person.serializable(value: someDate as Any) }.toNot(throwError())
                    expect { try Person.serializable(value: arrayOfUrl as Any) }.toNot(throwError())
                }
            }
            context("unsupported type") {
                it("Not serializable") {
                    struct A {}
                    expect { try Person.serializable(value: A() as Any) }.to(throwError(PersistentStorageSerializableTypeError.NonPlistType))
                }
            }
            context("Collection type") {
                context("of supported type values") {
                    let array: [Any] = [1, 3.0, "Hello", URL(string:"https://some.web")!]
                    let dictionary: [String : Any] = ["one" : 1, "two" : 3.0, "three" : "Hello", "four" : URL(string:"https://some.web")!]
                    it("serializable.") {
                        expect { try Person.serializable(value: array) }.toNot(throwError())
                        expect { try Person.serializable(value: dictionary) }.toNot(throwError())
                    }
                }
                context("with optionals") {
                    let array: [Any] = [1, Optional(3.0) as Any]
                    let dictionary: [String : Any] = ["one" : 1, "two" : Optional(3.0) as Any]
                    it("Not serializable.") {
                        expect { try Person.serializable(value: array) }.to(throwError(PersistentStorageSerializableTypeError.CollectionElement(.UnsupportedOptional)))
                        expect { try Person.serializable(value: dictionary) }.to(throwError(PersistentStorageSerializableTypeError.CollectionElement(.UnsupportedOptional)))
                    }
                }
                context("with unsupported type values") {
                    let array: [Any] = [1, 3.0, Person()]
                    let dictionary: [String : Any] = ["one" : 1, "two" : 3.0, "three" : Person()]
                    it("Not serializable.") {
                        expect { try Person.serializable(value: array) }.to(throwError(PersistentStorageSerializableTypeError.CollectionElement(.NonPlistType)))
                        expect { try Person.serializable(value: dictionary) }.to(throwError(PersistentStorageSerializableTypeError.CollectionElement(.NonPlistType)))
                    }
                }
            }
            context("Nested Collection type of supported type values") {
                let array: [Any] = [1, [3.0, ["Hello", [URL(string:"https://some.web")!]]]]
                let dictionary: [String : Any] = ["one" : 1, "nested" : ["two" : 3.0, "nested" : ["three" : "Hello", "nested" : ["four" : URL(string:"https://some.web")!]]]]
                it("serializable.") {
                    expect { try Person.serializable(value: array) }.toNot(throwError())
                    expect { try Person.serializable(value: dictionary) }.toNot(throwError())
                }
            }
        }
        
    }
}
