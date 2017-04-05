//
//  ViewController.swift
//  PersistentStorageSerializable
//
//  Created by IvanRublev on 04/05/2017.
//  Copyright (c) 2017 IvanRublev. All rights reserved.
//

import UIKit
import PersistentStorageSerializable

class ViewController: UIViewController {
    @IBOutlet var flagSwitch: UISwitch!
    @IBOutlet var textField: UITextField!
    @IBOutlet var numberStepper: UIStepper!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var userDefaultsLabel: UILabel!
    
    var settings: Settings!

    override func viewDidLoad() {
        super.viewDidLoad()
        load(0)
    }

    func updateViews() {
        flagSwitch.isOn = settings.flag
        textField.text = settings.title
        numberStepper.value = Double(settings.number)
        numberLabel.text = String(Int(numberStepper.value))
        userDefaultsLabel.text = try! String(describing: settings.persistedDictionaryRepresentation())
    }
}

// MARK: - Input controls actions
extension ViewController {
    @IBAction func updateSettings(_ sender: Any) {
        settings.flag = flagSwitch.isOn
        settings.title = textField.text ?? ""
        settings.number = Int(numberStepper.value)
        updateViews()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        textField.resignFirstResponder()
    }
}

// MARK: - Buttons actions
extension ViewController {
    @IBAction func load(_ sender: Any) {
        settings = try! Settings(from: UserDefaultsStorage.standard, keyPrefix: "Settings")
        updateViews()
    }
    
    @IBAction func save(_ sender: Any) {
        try! settings.persist()
        updateViews()
    }
    
    @IBAction func reset(_ sender: Any) {
        try! settings.removeFromPersistentStorage()
        updateViews()
    }
}
