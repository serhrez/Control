//
//  Constants.swift
//  ResizingTokenField
//
//  Created by Tadej Razborsek on 20/06/2019.
//  Copyright © 2019 Tadej Razborsek. All rights reserved.
//

import UIKit

public struct Constants {
    
    struct Font {
        public static var defaultFont: UIFont = UIFont.systemFont(ofSize: 15)
    }
    
    public struct Default {
        public static var animationDuration: TimeInterval = 0.3
        public static var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        public static var font: UIFont = UIFont.systemFont(ofSize: 15)
        public static var itemSpacing: CGFloat = 10
        public static var textFieldCellMinWidth: CGFloat = 60
        public static var labelTextColor: UIColor = .darkText
        public static var textFieldTextColor: UIColor = .darkText
        public static var defaultTokenTopBottomPadding: CGFloat = 2
        public static var defaultTokenLeftRightPadding: CGFloat = 12
        public static var defaultTokenCellConfiguration: DefaultTokenCellConfiguration = DefaultTokenCellInitialConfiguration()
    }
    
    public struct Identifier {
        public static var labelCell: String = "ResizingTokenFieldLabelCell"
        public static var tokenCell: String = "ResizingTokenFieldTokenCell"
        public static var textFieldCell: String = "ResizingTokenFieldTextFieldCell"
        public static var addCell: String = "ResizingTokenFieldAddCell"
    }
    
}

private struct DefaultTokenCellInitialConfiguration: DefaultTokenCellConfiguration {
    func cornerRadius(forSelected isSelected: Bool) -> CGFloat {
        return 5
    }
    
    func borderWidth(forSelected isSelected: Bool) -> CGFloat {
        return 0
    }
    
    func borderColor(forSelected isSelected: Bool) -> CGColor {
        return UIColor.black.cgColor
    }
    
    func textColor(forSelected isSelected: Bool) -> UIColor {
        return .darkText
    }
    
    func backgroundColor(forSelected isSelected: Bool) -> UIColor {
        return isSelected ? .gray : .lightGray
    }
    func cornerCurve(forSelected isSelected: Bool) -> CALayerCornerCurve {
        .continuous
    }
    func font(forSelected isSelected: Bool) -> UIFont {
        .systemFont(ofSize: 15, weight: .semibold)
    }
}
