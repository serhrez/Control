//
//  ResizingToken.swift
//  TodoApp
//
//  Created by sergey on 18.11.2020.
//

import Foundation
import ResizingTokenField

class ResizingToken: ResizingTokenFieldToken, Equatable {
    
    static func == (lhs: ResizingToken, rhs: ResizingToken) -> Bool {
        return lhs === rhs
    }
    
    var title: String
    
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
