//
//  ProjectDetailsTaskCreateVm.swift
//  TodoApp
//
//  Created by sergey on 23.12.2020.
//

import Foundation

struct ProjectDetailsTaskCreateModel {
    var priority: Priority
    var name: String
    var description: String
    var tags: [String]
    var date: Date?
    var reminder: Reminder?
    var repeatt: Repeat?
}
