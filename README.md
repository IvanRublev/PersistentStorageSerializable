# PersistentStorageSerializable

[![CI Status](http://img.shields.io/travis/IvanRublev/PersistentStorageSerializable.svg?style=flat)](https://travis-ci.org/IvanRublev/PersistentStorageSerializable)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/PersistentStorageSerializable.svg?style=flat)](http://cocoapods.org/pods/PersistentStorageSerializable)
[![Swift](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat)](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat)
[![License](https://img.shields.io/cocoapods/l/PersistentStorageSerializable.svg?style=flat)](http://cocoapods.org/pods/PersistentStorageSerializable)

`PersistentStorageSerializable` is a protocol for automatic serialization and deserialization of Swift class, struct or NSObject descendant object into and from User Defaults or Property List file.

The adopting type properties must be of property list type (String, Data, Date, Int, UInt, Float, Double, Bool, Array or Dictionary of above). If you want to store any other type of object, you should typically archive it to create an instance of Data. The URL properties can be stored in User Defaults storage but not in Plist storage. In the last case, you have to archive it to/from Data.

The `PersistentStorageSerializable` protocol provides default implementations of `init(from:)` initializer and `persist()` function. The library defines two classes of `PesistentStorage` protocol: `UserDefaultsStorage` and `PlistStorage`. Object of one of those types is passed as the argument when calling to `init(from:)` initializer to specify which storage to be used for serialization/deserialization.

Functions of the `PersistentStorageSerializable` protocol traverses the adopting type object and gets/sets it's properties values via [Reflection](https://github.com/Zewo/Reflection) library. The NSObject class descendant properties values are get/set via KVC.

## How to use

Serialize/Deserialize a struct with User Defaults by using `UserDefaultStorage` as shown below:

```swift
struct Settings: PersistentStorageSerializable {
    var flag = false
    var title = ""
    var number = 1
    var dictionary: [String : Any] = ["Number" : 1, "Distance" : 25.4, "Label" : "Hello"]

    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String! = "Settings"
}

// Init from User Defaults
var mySettings = try! Settings(from: UserDefaultsStorage.standard)

mySettings.flag = true

// Persist into User Defaults
try! mySettings.persist()
```

To serialize data with Plist file use `PlistStorage` class:

```swift
// Init from plist
let plistUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("storage.plist")

var settingsOnDisk = try! Settings(from: PlistStorage(at: plistUrl))

mySettings.flag = true

// Persist on disk
try! mySettings.persist()
```

### Reading data stored by the previous version of the app

When you have some data persisted in User Defaults by the previous version of the app and want to read that data into a structure you need to provide a mapping between properties names and User Defaults keys by overloading the `persistentStorageKey(for:)` function.

Say we have following data persisted in User Defaults:

```swift
UserDefaults.standard.set("Superhero", forKey: "oldGoogTitle")
UserDefaults.standard.set(true, forKey: "well.persisted.option")
```

We want those to be serialized with the object of `ApplicationConfiguration` class.

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
let configuration = try! ApplicationConfiguration(from: UserDefaultsStorage.standard)

print(configuration.title) // prints Superhero
print(configuration.showIntro) // prints true
```

## Example

To run example projects for iOS/macOS, run `pod try PersistentStorageSerializable` in the terminal.

## Requirements

- Xcode 8.3
- Swift 3.1

## Installation

### CocoaPods

PersistentStorageSerializable is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "PersistentStorageSerializable"
```

and run `pods update` or `pods install`.

### Carthage

If you use Carthage to manage your dependencies, simply add PersistentStorageSerializable to your Cartfile:

```
github "IvanRublev/PersistentStorageSerializable"
```

If you use Carthage to build your dependencies, make sure you have added `PersistentStorageSerializable.framework` and `Reflection.framework` to the "Linked Frameworks and Libraries" section of your target, and have included them in your Carthage framework copying build phase.

## Author

Copyright (c) 2017, IvanRublev, ivan@ivanrublev.me

## License

PersistentStorageSerializable is available under the MIT license. See the LICENSE file for more info.
