//
//  ModelFormatt.swift
//  TodoApp
//
//  Created by sergey on 21.12.2020.
//

import Foundation
import RealmSwift

class ModelFormatt {
    static func tagsSorted(tags: [RlmTag]) -> [RlmTag] {
        return tags.sorted(by: { (tag1: RlmTag, tag2: RlmTag) -> Bool in tag1.createdAt < tag2.createdAt })
    }
    
    static func tagsSorted(tags: [String]) -> [String] {
        return tags.sorted(by: { (tag1: String, tag2: String) -> Bool in tag1 < tag2 })
    }
}
