//
//  UICollectionSeparator.swift
//  TodoApp
//
//  Created by sergey on 28.12.2020.
//

import Foundation
import UIKit
import Material

class UICollectionSeparator: UICollectionReusableView {
    static let kind = "separatorkind"
    static let reuseId = "separatorid"
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "TABorder")!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UICollectionFractionalWidthSeparator: UICollectionReusableView {
    static let kind = "separatorkind"
    static let reuseId = "separatorid"
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "TAAltBackground")!
        let separator = UIView()
        layout(separator).leading(25).trailing(25).top().bottom()
        
        separator.backgroundColor = UIColor(named: "TABorder")!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
