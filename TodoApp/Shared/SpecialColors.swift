//
//  SpecialColors.swift
//  TodoApp
//
//  Created by sergey on 07.01.2021.
//

import Foundation
import UIKit

enum SpecialColors {
    static var addSomethingBg: UIColor {
        isLight ? UIColor.hex("#dfdfdf").withAlphaComponent(0.4) : UIColor.hex("#447bfe").withAlphaComponent(0.1)
    }
    static var addSomethingText: UIColor {
        isLight ? UIColor.hex("#a4a4a4") : UIColor.hex("#447bfe")
    }
    
    static var isLight: Bool {
        UIScreen.main.traitCollection.userInterfaceStyle == .light
    }
}
