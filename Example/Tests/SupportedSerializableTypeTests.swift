
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
                it("serializable.") {
                    expect(Person.serializable(value: someData as Any)) == true
                    expect(Person.serializable(value: someDate as Any)) == true
                }
            }
            context("unsupported types") {
                it("Not serializable") {
                    struct A {}
                    expect(Person.serializable(value: A() as Any)) == false
                }
            }
            context("Collection type") {
                context("of supported type values") {
                    let array: [Any] = [1, 3.0, "Hello", URL(string:"https://some.web")!]
                    let dictionary: [String : Any] = ["one" : 1, "two" : 3.0, "three" : "Hello", "four" : URL(string:"https://some.web")!]
                    it("serializable.") {
                        expect(Person.serializable(value: array)) == true
                        expect(Person.serializable(value: dictionary)) == true
                    }
                }
                context("with optionals") {
                    let array: [Any] = [1, Optional(3.0) as Any]
                    let dictionary: [String : Any] = ["one" : 1, "two" : Optional(3.0) as Any]
                    it("Not serializable.") {
                        expect(Person.serializable(value: array)) == false
                        expect(Person.serializable(value: dictionary)) == false
                    }
                }
                context("with unsupported type values") {
                    let array: [Any] = [1, 3.0, Person()]
                    let dictionary: [String : Any] = ["one" : 1, "two" : 3.0, "three" : Person()]
                    it("Not serializable.") {
                        expect(Person.serializable(value: array)) == false
                        expect(Person.serializable(value: dictionary)) == false
                    }
                }
            }
            context("Nested Collection type of supported type values") {
                let array: [Any] = [1, [3.0, ["Hello", [URL(string:"https://some.web")!]]]]
                let dictionary: [String : Any] = ["one" : 1, "nested" : ["two" : 3.0, "nested" : ["three" : "Hello", "nested" : ["four" : URL(string:"https://some.web")!]]]]
                it("serializable.") {
                    expect(Person.serializable(value: array)) == true
                    expect(Person.serializable(value: dictionary)) == true
                }
            }
        }
        
    }
}
