//
//  RlmArchived.swift
//  TodoApp
//
//  Created by sergey on 16.12.2020.
//

import Foundation
import RealmSwift
import UIKit

final class RlmArchived: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var taskId: String = ""
    @objc dynamic var timeDeleted: Date = .init()
    
    convenience init(taskId: String, timeDeleted: Date) {
        self.init()
        self.taskId = taskId
        self.timeDeleted = timeDeleted
    }
    
    override class func primaryKey() -> String? {
        RlmArchived.Property.id.rawValue
    }

}

extension RlmArchived {
    enum Property: String {
        case id, taskId, timeDeleted
    }
}
