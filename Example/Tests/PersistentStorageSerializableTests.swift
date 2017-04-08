// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import PersistentStorageSerializable

let memoryStorage = PersistentStorageMock()

// MARK: These are persistable types.
struct Person: PersistentStorageSerializable {
    var name: String = "Dory"
    var birthday: Date = Date()
    var web: URL = URL(string: "https://dory.me")!
    var age: Int = 25
    var addressDistance: Dictionary<String, Float> = ["Kensington rd. 75" : 125.8, "Portland ave. 15" : 245.6]
    var favoriteNumbers = [1, 7, 9]
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage! = Person.defaultPersistentStorage
    var persistentStorageKeyPrefix: String! = Person.defaultPersistentStorageKeyPrefix
}

extension Person {
    static let defaultPersistentStorage = memoryStorage
    static let defaultPersistentStorageKeyPrefix = "Person"
}

extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        return
            lhs.name == rhs.name &&
            abs(rhs.birthday.timeIntervalSince(lhs.birthday)) < 0.2 &&
            lhs.web == rhs.web &&
            lhs.age == rhs.age &&
            lhs.addressDistance == rhs.addressDistance &&
            lhs.favoriteNumbers == rhs.favoriteNumbers
    }
}

final class Vehicle: PersistentStorageSerializable {
    var wheels: Int = 4
    var doors: Int = 3
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String! = "Car"
}

final class Location: NSObject, PersistentStorageSerializable {
    dynamic var street: String = ""
    dynamic var houseNo: Int = 0
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage! = memoryStorage
    var persistentStorageKeyPrefix: String! = "Location"
}

class PersistableTypeTests: QuickSpec {
    override func spec() {
        let initialPerson = Person()
        
        describe("After first push of object to storage, initial values") {
            let aPerson = Person()
            beforeEach {
                memoryStorage.registeredDefaultValues = nil
            }
            
            it("registered with storage.") {
                expect { try aPerson.pushToPersistentStorage() }.toNot(throwError())
                expect(memoryStorage.registeredDefaultValues).toNot(beNil())
            }
            context("and on following push") {
                it("not registered with storage.") {
                    expect { try aPerson.pushToPersistentStorage() }.toNot(throwError())
                    expect(memoryStorage.registeredDefaultValues).to(beNil())
                }
            }
        }

        describe("Swift class object properties values are") {
            let persistedDoors = 5
            beforeEach {
                memoryStorage.values["Car.doors"] = persistedDoors
            }
            context("initialized from storage") {
                var car: Vehicle!
                it("successfully initialized.") {
                    expect { car = try Vehicle(from: memoryStorage) }.toNot(throwError())
                    expect(car.doors) == persistedDoors
                }
                context("modified and persisted to storage") {
                    let newWheels = 3
                    it("successfully persisted.") {
                        car.wheels = newWheels
                        expect { try car.persist() }.toNot(throwError())
                        expect(memoryStorage.values["Car.wheels"] as! Int?) == newWheels
                    }
                }
            }
        }
        
        describe("Swift class object properties values are") {
            context("initializable from plist") {
                var car: Vehicle!
                var documentsCarUrl: URL?
                beforeEach {
                    let plistFileName = "Car.plist"
                    let bundledCarUrl = URL(fileURLWithPath: Bundle(for: Vehicle.self).path(forResource: plistFileName, ofType: nil)!)
                    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
                    documentsCarUrl = documentsUrl.appendingPathComponent(plistFileName)
                    print(documentsCarUrl!)
                    try? FileManager.default.removeItem(at: documentsCarUrl!)
                    try! FileManager.default.copyItem(at: bundledCarUrl, to: documentsCarUrl!)
                    expect { car = try Vehicle(from: PlistStorage(at: documentsCarUrl!), keyPrefix: "Car") }.toNot(throwError())
                }
                afterSuite {
                    if let documentsCarUrl = documentsCarUrl {
                        try? FileManager.default.removeItem(at: documentsCarUrl)
                    }
                }
                it("successfully initialized.") {
                    expect(car.wheels) == 4
                    expect(car.doors) == 7
                }
                context("modified and persisted") {
                    beforeEach {
                        car.wheels = 3
                        expect { try car.persist() }.toNot(throwError())
                    }
                    it("successfully persisted.") {
                        var car2: Vehicle!
                        expect { car2 = try Vehicle(from: PlistStorage(at: documentsCarUrl!), keyPrefix: "Car") }.toNot(throwError())
                        expect(car2.wheels) == 3
                        expect(car2.doors) == 7
                    }
                }
            }
        }
        
        describe("NSObject descendant object properties values are") {
            var loc: Location!
            let newStreet = "Holmes"
            let newHouseNo = 128
            beforeEach {
                loc = Location()
            }
            context("when pushed") {
                it("persisted.") {
                    loc.street = newStreet
                    loc.houseNo = newHouseNo
                    expect { try loc.pushToPersistentStorage() }.toNot(throwError())
                    expect(memoryStorage.values[loc.persistentStorageKey(for: "street")] as! String?) == newStreet
                    expect(memoryStorage.values[loc.persistentStorageKey(for: "houseNo")] as! Int?) == newHouseNo
                }
            }
            context("when pulled") {
                beforeEach {
                    memoryStorage.values[loc.persistentStorageKey(for: "street")] = newStreet
                    memoryStorage.values[loc.persistentStorageKey(for: "houseNo")] = newHouseNo
                }
                it("restored.") {
                    expect { try loc.pullFromPersistentStorage() }.toNot(throwError())
                    expect(loc.street) == newStreet
                    expect(loc.houseNo) == newHouseNo
                }
            }
        }
        
        describe("Swift struct value properties values are") {
            var aPerson: Person!
            
            beforeEach {
                aPerson = initialPerson
            }
            context("not persisted in storage") {
                beforeEach {
                    memoryStorage.values.removeAll()
                }
                context("after pull") {
                    it("same as initial.") {
                        expect { try aPerson.pullFromPersistentStorage() }.toNot(throwError())
                        expect(aPerson) == initialPerson
                    }
                }
                context("modified") {
                    let newName = "Mary Wong"
                    let newFavoriteNumbers = [2, 8, 5]
                    beforeEach {
                        aPerson.name = newName
                        aPerson.favoriteNumbers = newFavoriteNumbers
                    }
                    context("then pushed and pulled from storage") {
                        beforeEach {
                            try! aPerson.pushToPersistentStorage()
                            aPerson = initialPerson
                            try! aPerson.pullFromPersistentStorage()
                        }
                        it("keept modified.") {
                            expect(aPerson.name) == newName
                            expect(aPerson.favoriteNumbers) == newFavoriteNumbers
                        }
                    }
                }
            }
            context("persistent in storage") {
                let persistedPerson = Person(name: "Ada",
                                             birthday: Date(timeIntervalSinceReferenceDate:0),
                                             web: URL(string: "https://ada.me")!,
                                             age: 23,
                                             addressDistance: ["Banhof st. 22" : 178.1, "Ludvig st. 55": 345.8],
                                             favoriteNumbers: [8, 3, 5],
                                             persistentStorage: Person.defaultPersistentStorage,
                                             persistentStorageKeyPrefix: Person.defaultPersistentStorageKeyPrefix)
                beforeEach {
                    memoryStorage.values[persistedPerson.persistentStorageKey(for: "name")] = persistedPerson.name
                    memoryStorage.values[persistedPerson.persistentStorageKey(for: "birthday")] = persistedPerson.birthday
                    memoryStorage.values[persistedPerson.persistentStorageKey(for: "web")] = persistedPerson.web
                    memoryStorage.values[persistedPerson.persistentStorageKey(for: "age")] = persistedPerson.age
                    memoryStorage.values[persistedPerson.persistentStorageKey(for: "addressDistance")] = persistedPerson.addressDistance
                    memoryStorage.values[persistedPerson.persistentStorageKey(for: "favoriteNumbers")] = persistedPerson.favoriteNumbers
                }
                context("after pool") {
                    it("same as in storage.") {
                        expect { try aPerson.pullFromPersistentStorage() }.toNot(throwError())
                        expect(aPerson) == persistedPerson
                    }
                }
                
                describe("Persistent representation dictionary") {
                    var dictionary: [String : Any]!
                    var memoryStorageValuesCount = 0
                    beforeEach {
                        memoryStorageValuesCount = memoryStorage.values.count
                        dictionary = try! persistedPerson.persistedDictionaryRepresentation()
                    }
                    it("same count as in storage.") {
                        expect(dictionary.count) == memoryStorageValuesCount
                    }
                }
                
                context("after remove from storage") {
                    beforeEach {
                        try! persistedPerson.removeFromPersistentStorage()
                    }
                    describe("Storage") {
                        it("empty.") {
                            expect(memoryStorage.values.count) == 0
                        }
                    }
                }
            }
        }
        
        describe("Swift struct properties values are") {
            context("persisted under custom keys in storage") {
                let name = "Bob"
                let age = 55
                beforeEach {
                    memoryStorage.values["person.name"] = name
                    memoryStorage.values["person.age"] = age
                }
                context("keys are mapped and we pull from storage") {
                    struct OtherPerson: PersistentStorageSerializable {
                        var name: String = "Dory"
                        var age: Int = 25
                        
                        // MARK: Adopt PersistentStorageSerializable
                        var persistentStorage: PersistentStorage!
                        var persistentStorageKeyPrefix: String!
                        
                        func persistentStorageKey(for propertyName: String) -> String {
                            let keyMap = ["name": "person.name", "age": "person.age"]
                            return keyMap[propertyName]!
                        }
                    }
                    
                    it("pulled with success.") {
                        var person = OtherPerson()
                        expect { person = try OtherPerson(from: memoryStorage, keyPrefix: "") }.toNot(throwError())
                        expect(person.name) == name
                        expect(person.age) == age
                    }
                }
            }
        }
       
    }
}

// MARK: - This is Not persistable, will throw exception at runtime.
struct Address: PersistentStorageSerializable {
    struct Street {
        var name: String
        var central: Bool
    }
    
    var street: Street = Street(name: "Kensington rd. 85", central: true)
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage! = memoryStorage
    var persistentStorageKeyPrefix: String! = "Address"
}

class UnpersistableTypeTests: QuickSpec {
    override func spec() {
        describe("Address object's properties values") {
            context("when pushed to storage") {
                it("throws an exception with street property because Street type is not a serializable type") {
                    let address = Address()
                    expect { try address.pushToPersistentStorage() }.to(throwError(PersistentStorageSerializableError.UnsupportedValueTypeForKey("street")))
                }
            }
        }
    }
}
