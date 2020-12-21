//
//  ResizingToken.swift
//  TodoApp
//
//  Created by sergey on 18.11.2020.
//

import Foundation
import ResizingTokenField
import DeepDiff

class ResizingToken: ResizingTokenFieldToken, Equatable, DiffAware {
    static func compareContent(_ a: ResizingToken, _ b: ResizingToken) -> Bool {
        a == b
    }
    
    static func == (lhs: ResizingToken, rhs: ResizingToken) -> Bool {
        return lhs.title == rhs.title
    }
    
    var title: String
    var diffId: String { title }
    
    init(title: String) {
        self.title = title
    }
}

class ResizingTokenConfiguration: DefaultTokenCellConfiguration {
    func cornerRadius(forSelected isSelected: Bool) -> CGFloat {
        return 11
    }
    
    func borderWidth(forSelected isSelected: Bool) -> CGFloat {
        return 0
    }
    
    func borderColor(forSelected isSelected: Bool) -> CGColor {
        return UIColor.clear.cgColor
    }
    
    func textColor(forSelected isSelected: Bool) -> UIColor {
        return UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1)
    }
    
    func backgroundColor(forSelected isSelected: Bool) -> UIColor {
        return isSelected ? UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1).withAlphaComponent(0.2) : UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1).withAlphaComponent(0.1)
    }
    
    func cornerCurve(forSelected isSelected: Bool) -> CALayerCornerCurve {
        return .continuous
    }
}
