//
//  AppSettings.swift
//  PersistentStorageSerializable
//
//  Created by Ivan Rublev on 4/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import PersistentStorageSerializable

final class AppSettings: NSObject, PersistentStorageSerializable {
    dynamic var flag = false
    dynamic var title = "Default text"
    dynamic var number = 1
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage! = PlistStorage(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("storage.plist"))
    var persistentStorageKeyPrefix: String! = "AppSettings"
}
