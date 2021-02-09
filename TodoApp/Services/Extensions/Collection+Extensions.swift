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

extension Array {
    func randomElement() -> Element? {
        guard let firstIndex = indices.first,
           let lastIndex = indices.last else { return nil }
        return self[Int.random(in: firstIndex...lastIndex)]
    }
}
