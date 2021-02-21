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
    func localizable(argument: String) -> String {
        return String(format: NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self), argument)
    }
    func localizable(argument: String, argument2: String) -> String {
        return String(format: NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self), argument, argument2)
    }
    func localizable(argument: String, argument2: String, argument3: String) -> String {
        return String(format: NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self), argument, argument2, argument3)
    }


}
