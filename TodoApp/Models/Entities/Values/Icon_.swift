//
//  Icon.swift
//  Todo
//
//  Created by sergey on 13.09.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation

enum Icon {
    case text(String)
    case image(URL)
    case assetImage(String)
    
    init(rawValue: String) {
        switch rawValue {
        case let x where x.starts(with: "t"):
            self = .text(String(x.dropFirst()))
        case let x where x.starts(with: "i"):
            self = .image(URL(fileURLWithPath: String(x.dropFirst())))
        case let x where x.starts(with: "a"):
            self = .assetImage(String(x.dropFirst()))
        default:
            self = .text("")
        }
    }
    
    var rawValue: String {
        switch self {
        case let .text(text): return "t\(text)"
        case let .image(url): return "i\(url.absoluteString)"
        case let .assetImage(imageName): return "a\(imageName)"
        }
    }
}
