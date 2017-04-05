# PersistentStorageSerializable

[![CI Status](http://img.shields.io/travis/IvanRublev/PersistentStorageSerializable.svg?style=flat)](https://travis-ci.org/IvanRublev/PersistentStorageSerializable) [![Version](https://img.shields.io/cocoapods/v/PersistentStorageSerializable.svg?style=flat)](http://cocoapods.org/pods/PersistentStorageSerializable) [![Swift](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat)](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat) [![License](https://img.shields.io/cocoapods/l/PersistentStorageSerializable.svg?style=flat)](http://cocoapods.org/pods/PersistentStorageSerializable)

This Swift library makes easier to serialize the user's preferences (app's settings) with system User Defaults or Property List file on disk. Simply by making class / struct / NSObject descendant type to adopt `PersistentStorageSerializable` protocol.

The limit is that serializable type properties must be of property list object types (String, Data, Date, Int, UInt, Float, Double, Bool, Array or Dictionary of above). And URL in case of User Defaults. If you want to store any other type of object, you should typically archive it to create an instance of NSData.

Serialization functions of the protocol traverses the type instance and get/set properties values automatically via [Reflection](https://github.com/Zewo/Reflection) library. To set NSObject class descendant type properties KVC is used.

## How to use

Serialize a type properties value with User Defaults as following:

```swift
struct Settings: PersistentStorageSerializable {
    var flag = false
    var title = ""
    var number = 1
    var dictionary: [String : Any] = ["Number" : 1, "Distance" : 25.4, "Label" : "Hello"]

    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String!
}

// Init from User Defaults
let mySettings = Settings(from: UserDefaultsStorage.standard, keyPrefix: "Settings")

mySettings.flag = true

// Persist into User Defaults
mySettings.persist()
```

Or serialize with Plist file using `PlistStorage` class:

```swift
// Init from plist
let plistUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("storage.plist")

let settingsOnDisk = try! Settings(from: PlistStorage(at: plistUrl), keyPrefix: "Settings")

mySettings.flag = true

// Persist on disk
try! mySettings.persist()
```

It's possible to make custom storage class by adopting `PersistentStorage` protocol.

### Reading data stored by the previous version of the app

When you have some data persisted in User Defaults by the previous version of the app and want PersistentStorageSerializable library to read that data into your structure you need to provide a mapping between properties names and User Defaults keys.

Say we have following data persisted in User Defaults:

```swift
UserDefaults.standard.set("Superhero", forKey: "oldGoogTitle")
UserDefaults.standard.set(true, forKey: "well.persisted.option")
```

We want those to be serialized with the `ApplicationConfiguration` class.

```swift
final class ApplicationConfiguration: PersistentStorageSerializable {
    var title = ""
    var showIntro = false

    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String!
}


// Provide key mapping by overloading `persistentStorageKey(for:)` function.
extension ApplicationConfiguration {
    func persistentStorageKey(for propertyName: String) -> String {
        let keyMap = ["title" : "oldGoogTitle", "showIntro" : "well.persisted.option"]
        return keyMap[propertyName]!
    }
}

// Now we can load data persisted in the storage.
let configuration = try! ApplicationConfiguration(from: UserDefaultsStorage.standard, keyPrefix: "")

print(configuration.title) // prints Superhero
print(configuration.showIntro) // prints true
```

## Example

To run example projects for iOS/macOS, open console and run `pod try PersistentStorageSerializable`.

## Requirements

- XCode 8.3
- Swift 3.1

## Installation

PersistentStorageSerializable is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "PersistentStorageSerializable"
```

and run `pods update` or `pods install`.

## Author

Copyrigth (c) 2017, IvanRublev, ivan@ivanrublev.me

## License

PersistentStorageSerializable is available under the MIT license. See the LICENSE file for more info.
