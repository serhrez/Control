//
//  Array+Extensions.swift
//  TodoApp
//
//  Created by sergey on 08.02.2021.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
