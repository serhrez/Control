//
//  SwipeExpansionStyle+Extensions.swift
//  TodoApp
//
//  Created by sergey on 02.01.2021.
//

import Foundation
import SwipeCellKit

extension SwipeExpansionStyle {
    static let todoCustom = SwipeExpansionStyle(target: .percentage(0.25), additionalTriggers: [], elasticOverscroll: false, completionAnimation: .fill(.manual(timing: .after)))
}
