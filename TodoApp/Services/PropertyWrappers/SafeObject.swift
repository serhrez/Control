//
//  SafeObject.swift
//  TodoApp
//
//  Created by sergey on 04.01.2021.
//

import Foundation
import RealmSwift

@propertyWrapper struct SafeObject<Obj: Object> {
    var internalValue: Obj
    var wrappedValue: Obj {
        get {
            guard !internalValue.isInvalidated else {
                fatalError("Was accessed invalidated object. This line should be deleted in production")
                return Obj()
            }
            return internalValue
        }
        set {
            internalValue = newValue
        }
    }
    
    init(wrappedValue: Obj) {
        self.internalValue = wrappedValue
    }
}
