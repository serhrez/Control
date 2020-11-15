//
//  Tag.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import RealmSwift

final class RlmTag: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var createdAt = Date()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }

    override class func primaryKey() -> String? {
        Self.Property.id.rawValue
    }
}

extension RlmTag {
    enum Property: String {
        case id, name, createdAt
    }
}
