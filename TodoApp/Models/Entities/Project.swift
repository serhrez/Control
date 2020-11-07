//
//  Project.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

final class Project: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var notes: String? = nil
    let tasks = List<Task>()
    @objc dynamic var createdAt = Date()
    
    @objc dynamic private var _icon = ""
    var icon: Icon {
        get { return Icon(rawValue: _icon) }
        set { _icon = newValue.rawValue }
    }
    
    @objc dynamic private var _color = ""
    var color: UIColor {
        get { return UIColor(hex: _color) ?? .white }
        set {
            if let hex = newValue.toHex {
                _color = hex
            }
        }
    }
    
    override static func primaryKey() -> String? {
        return Project.Property.id.rawValue
    }
    
    convenience init(name: String, icon: Icon = Icon.text(""), notes: String? = nil, color: UIColor = .red, date: Date = Date()) {
        self.init()
        self.name = name
        self.notes = notes
        self.icon = Icon.text("🚒")
        self.color = color
        self.createdAt = date
    }
}

extension Project {
    enum Property: String {
        case id, name, notes, createdAt, _icon, _color
    }
}
