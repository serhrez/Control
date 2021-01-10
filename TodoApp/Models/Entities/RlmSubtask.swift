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
    @objc dynamic var isDone = false
    
    convenience init(name: String, createdAt: Date = Date(), isDone: Bool = false) {
        self.init()
        self.name = name
        self.createdAt = createdAt
        self.isDone = isDone
    }
    
    override class func primaryKey() -> String? {
        RlmSubtask.Property.id.rawValue
    }
}

extension RlmSubtask {
    enum Property: String {
        case id, name, createdAt, isDone
    }
}
