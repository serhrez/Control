//
//  Subtask.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import RealmSwift

final class RlmSubtask: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var createdAt = Date()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override class func primaryKey() -> String? {
        RlmSubtask.Property.id.rawValue
    }
}

extension RlmSubtask {
    enum Property: String {
        case id, name, createdAt
    }
}

