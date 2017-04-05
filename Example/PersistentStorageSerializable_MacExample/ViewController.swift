//
//  ViewController.swift
//  PersistentStorageSerializable_MacExample
//
//  Created by Ivan Rublev on 4/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var userDefaultsText: NSTextField!

    dynamic var settings = AppSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load(0)
    }

    func updateUserDefaultsText() {
        userDefaultsText.stringValue = try! String(describing: settings.persistedDictionaryRepresentation())
    }
    
    @IBAction func load(_ sender: Any) {
        view.window?.makeFirstResponder(nil)
        var loadedSettings = AppSettings()
        try! loadedSettings.pullFromPersistentStorage()
        settings = loadedSettings
        updateUserDefaultsText()
    }

    @IBAction func save(_ sender: Any) {
        view.window?.makeFirstResponder(nil)
        try! settings.pushToPersistentStorage()
        updateUserDefaultsText()
    }

    @IBAction func reset(_ sender: Any) {
        view.window?.makeFirstResponder(nil)
        try! settings.removeFromPersistentStorage()
        updateUserDefaultsText()
    }

}
