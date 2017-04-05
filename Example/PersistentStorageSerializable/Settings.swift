//
//  Settings.swift
//  PersistentStorageSerializable
//
//  Created by Ivan Rublev on 4/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import PersistentStorageSerializable

struct Settings: PersistentStorageSerializable {
    var flag = false
    var title = ""
    var number = 1
    
    // MARK: Adopt PersistentStorageSerializable
    var persistentStorage: PersistentStorage!
    var persistentStorageKeyPrefix: String!
}
