//
//  String+Extensions.swift
//  TodoApp
//
//  Created by sergey on 20.02.2021.
//

import Foundation

extension String {
    func localizable(comment: String? = nil) -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: comment ?? self)
    }
}
