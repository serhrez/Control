//
//  AnimatableSectionModel.swift
//  TodoApp
//
//  Created by sergey on 15.11.2020.
//

import Foundation
import RxDataSources

struct AnimSection<Item: IdentifiableType & Equatable>: AnimatableSectionModelType, IdentifiableType {
    var items: [Item]
    var identity: String = "asm"
    
    init(original: AnimSection<Item>, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(identity: String = "asm", items: [Item]) {
        self.identity = identity
        self.items = items
    }
}
