//
//  CascadeDeleting.swift
//  TodoApp
//
//  Created by sergey on 11.01.2021.
//

import Foundation
import RealmSwift

protocol CascadeDeleting {
    func hardCascadeDeleteProperties() -> [String]
}

extension Realm {
    func cascadeDelete(_ object: Object) {
        defer { delete(object) }
        guard let cascading = object as? CascadeDeleting else { return }
        for property in cascading.hardCascadeDeleteProperties() {
            if let linkedObject = object.value(forKey: property) as? Object {
                cascadeDelete(linkedObject)
                continue
            }
            if let linkedObjects = object.value(forKey: property) as? ListBase { (0..<linkedObjects._rlmArray.count)
                .compactMap {
                    linkedObjects._rlmArray.object(at: $0) as? Object
                }
                .forEach(cascadeDelete)
                continue
            }
        }
    }
}
