//
//  ProjectSorting.swift
//  TodoApp
//
//  Created by sergey on 31.12.2020.
//

import Foundation

enum ProjectSorting: String {
    case byCreatedAt
    case byPriority
    case byName
    case byDate
    
    static let allCases: [ProjectSorting] = [.byCreatedAt, .byPriority, .byName, .byDate]
    var name: String {
        switch self {
        case .byCreatedAt: return "Sort by created".localizable()
        case .byPriority: return "Sort by priority".localizable()
        case .byName: return "Sort by name".localizable()
        case .byDate: return "Sort by date".localizable()
        }
    }
}
