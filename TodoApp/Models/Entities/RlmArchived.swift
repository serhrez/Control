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
    @objc dynamic var task: RlmTask?
    @objc dynamic var projectId: String = ""
    @objc dynamic var timeDeleted: Date = .init()
        
    convenience init(task: RlmTask, projectId: String) {
        self.init()
        self.task = task
        self.projectId = projectId
    }
    
    override class func primaryKey() -> String? {
        RlmArchived.Property.id.rawValue
    }

}

extension RlmArchived {
    enum Property: String {
        case id, task, projectId, timeDeleted
    }
}

extension RlmArchived: CascadeDeleting {
    func hardCascadeDeleteProperties() -> [String] {
        [Property.task.rawValue]
    }
}
