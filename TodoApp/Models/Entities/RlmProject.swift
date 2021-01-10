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

final class RlmProject: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var notes: String? = nil
    let tasks = List<RlmTask>()
    @objc dynamic var createdAt = Date()
    
    @objc dynamic private var _icon: Data = #"{"text":"🎥"}"#.data(using: .utf8) ?? Data()
    var icon: Icon {
        get {
            do {
                let icon = try JSONDecoder().decode(Icon.self, from: _icon)
                return icon
            } catch {
                print("error: \(error.localizedDescription) with data: \(String(data: _icon, encoding: .utf8) ?? "nodata")")
                return .text("")
            }
        }
        set {
            do {
                _icon = try JSONEncoder().encode(newValue)
            } catch {
                print("error: \(error.localizedDescription) with icon: \(newValue)")
            }
        }
    }
    
    @objc dynamic private var _color = ""
    var color: UIColor {
        get { return UIColor(hex: _color) ?? .hex("#FF9900") }
        set {
            if let hex = newValue.toHex {
                _color = hex
            }
        }
    }
    
    @objc dynamic var _sorting: String = ProjectSorting.byCreatedAt.rawValue
    var sorting: ProjectSorting {
        get {
            if ProjectSorting(rawValue: _sorting) == nil { fatalError() }
            return ProjectSorting(rawValue: _sorting) ?? .byCreatedAt
        }
        set {
            _sorting = newValue.rawValue
        }
    }
    
    override static func primaryKey() -> String? {
        return RlmProject.Property.id.rawValue
    }
    
    convenience init(name: String, icon: Icon = Icon.text(""), notes: String? = nil, color: UIColor = .red, date: Date = Date()) {
        self.init()
        self.name = name
        self.notes = notes
        self.icon = icon
        self.color = color
        self.createdAt = date
    }
}

extension RlmProject {
    enum Property: String {
        case id, name, notes, tasks, createdAt, _icon, _color
    }
}

extension RlmProject: CascadeDeleting {
    func hardCascadeDeleteProperties() -> [String] {
        [Property.tasks.rawValue]
    }
}
