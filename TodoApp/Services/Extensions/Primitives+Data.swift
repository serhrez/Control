//
//  Primitives+Data.swift
//  TodoApp
//
//  Created by sergey on 17.02.2021.
//

import Foundation

extension Bool {

    var data:NSData {
        var _self = self
        return NSData(bytes: &_self, length: MemoryLayout.size(ofValue: self))
    }

    init?(data:NSData) {
        guard data.length == 1 else { return nil }
        var value = false
        data.getBytes(&value, length: MemoryLayout<Bool>.size)
        self = value
    }
}
