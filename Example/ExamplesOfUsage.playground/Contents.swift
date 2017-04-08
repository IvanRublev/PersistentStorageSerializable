//: # PersistentStorageSerializable library. 
import UIKit
import PersistentStorageSerializable

/*:
 ## Custom persistent storage
 
 Usually, we use `UserDefaultsStorage` class provided by the library to serialize type values with the system user defaults.
 
 We can define a custom persistent storage by adopting `PersistentStorage` protocol. Let's define a memory storage and use it instead `UserDefaultsStorage` for demonstration purposes.
 */
final class MemoryStorage {
    var dictionary = [String : Any]()
}

extension MemoryStorage: PersistentStorage {
    func beginTransaction() throws {}
    
    func register(defaultValues: [String : Any]) {}
    
    func get(valueOf key: String) -> Any? {
        return dictionary[key]
    }
    
    func set(value: Any?, for key: String) throws {
        dictionary[key] = value
    }
    
    func finishTransaction() throws {}
}

let memoryStorage = MemoryStorage()

/*:
 ---
 
 ## Serializing a struct type
 
 Declare struct type for your user preferences and adopt `PersistentStorageSerializable` protocol.
 */
struct UserPreferences: PersistentStorageSerializable {
    var myString = "Hello"
    var myBool = false
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String! = "UserPreferences"
}

memoryStorage.dictionary

var preferences = try! UserPreferences(from: memoryStorage)

preferences.myString = "Greetings"
preferences.myBool = true

try! preferences.persist()

//: Preferences values are persisted in storage.
memoryStorage.dictionary

/*:
 ---

 ## Serializing a class type
 
 If we use classes as a data structure for settings then we can use a custom subclass to adopt serialization functionality.
 */
class Serializable: PersistentStorageSerializable {
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String!
    
    required init() {}
}

class AppSettings: Serializable {
    var myUInt = UInt.max
    var myDouble = 125.76
    
//: - We can use only plist types and collections of such types for properties. If we have to persist some other type we should convert it to plist one as shown below.
    var _myColor = [Float](arrayLiteral: 0, 0, 0, 0)
    var myColor: UIColor {
        get {
            return UIColor(colorLiteralRed: _myColor[0], green: _myColor[1], blue: _myColor[2], alpha: _myColor[3])
        }
        set {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            newValue.getRed(&r, green: &g, blue: &b, alpha: &a)
            _myColor = [Float(r), Float(g), Float(b), Float(a)]
        }
    }
    
}

var settings = try! AppSettings(from: memoryStorage, keyPrefix: "AppSettings")
settings.myColor = UIColor.red
try! settings.persist()

//: The memory storage contains values of both `preferences` and `settings` instances.
memoryStorage.dictionary

/*:
 ---

 ## Reading data stored by the previous version of the app
 
 When you have some data persisted in user defaults by the previous version of the app and want `PersistentStorageSerializable` library to read that data into your structure you need to provide a mapping between properties names and User Defaults keys.

 Say we have our data persisted in storage.
*/
memoryStorage.dictionary.removeAll()
memoryStorage.dictionary["oldGoogTitle"] = "Superhero"
memoryStorage.dictionary["well.persisted.option"] = true
memoryStorage.dictionary

//: We want those to be serialized with the following class.
final class ApplicationConfiguration: PersistentStorageSerializable {
    var title = ""
    var showIntro = false
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String!
}

//: Provide key mapping by overloading `persistentStorageKey(for:)` function.
extension ApplicationConfiguration {
    func persistentStorageKey(for propertyName: String) -> String {
        let keyMap = ["title" : "oldGoogTitle", "showIntro" : "well.persisted.option"]
        return keyMap[propertyName]!
    }
}

//: Now we can load data persisted in the storage.
let configuration = try! ApplicationConfiguration(from: memoryStorage, keyPrefix: "")

configuration.title
configuration.showIntro

//: ### Same with a custom subclass
class SerializableWithKeyMap: PersistentStorageSerializable {
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String!
    
    required init() {}
    
    var keyMap: [String : String]!
    
    func persistentStorageKey(for propertyName: String) -> String {
        return keyMap[propertyName]!
    }
}

class ApplicationConfiguration2: SerializableWithKeyMap {
    var title = ""
    var showIntro = false
    
    required init() {
        super.init()
        keyMap = ["title" : "oldGoogTitle", "showIntro" : "well.persisted.option"]
    }
}

let configuration2 = try! ApplicationConfiguration2(from: memoryStorage, keyPrefix: "")

configuration2.title
configuration2.showIntro


/*:
 
 ---
*/
