//
//  Subtask.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import RealmSwift

final class Subtask: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var createdAt = Date()
    
    override class func primaryKey() -> String? {
        Subtask.Property.id.rawValue
    }
}

extension Subtask {
    enum Property: String {
        case id, name, createdAt
    }
}

