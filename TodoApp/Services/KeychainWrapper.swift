//
//  KeychainWrapper.swift
//  TodoApp
//
//  Created by sergey on 17.02.2021.
//

import Foundation
import KeychainAccess

class KeychainWrapper {
    private let keychain = Keychain()
    static let shared = KeychainWrapper()
    
    var isPremium: Bool {
        set {
            keychain["isPremium"] = newValue ? "true" : "false"
        }
        get {
            keychain["isPremium"] == "true"
        }
    }
}
