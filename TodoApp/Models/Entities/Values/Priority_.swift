//
//  Priority.swift
//  Todo
//
//  Created by sergey on 13.09.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import UIKit

enum Priority: String, Hashable {
    case none
    case low
    case medium
    case high
}
extension Priority {
    var color: UIColor {
        switch self {
        case .high: return .hex("#EF4439")
        case .medium: return .hex("#FF9900")
        case .low: return .hex("#447BFE")
        case .none: return .hex("#DFDFDF")
        }
    }
}
