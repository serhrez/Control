//
//  UIFont+Extensions.swift
//  TodoApp
//
//  Created by sergey on 22.02.2021.
//

import Foundation
import UIKit

extension UIFont {
    
    func getFontWeight() -> UIFont.Weight {
        let fontAttributeKey = UIFontDescriptor.AttributeName.init(rawValue: "NSCTFontUIUsageAttribute")
        if let fontWeight = self.fontDescriptor.fontAttributes[fontAttributeKey] as? String {
            switch fontWeight {
            case "CTFontRegularUsage":
                return UIFont.Weight.regular
            case "CTFontBoldUsage":
                return UIFont.Weight.bold
            case "CTFontBlackUsage":
                return UIFont.Weight.black
            case "CTFontHeavyUsage":
                return UIFont.Weight.heavy
            case "CTFontUltraLightUsage":
                return UIFont.Weight.ultraLight
            case "CTFontThinUsage":
                return UIFont.Weight.thin
            case "CTFontLightUsage":
                return UIFont.Weight.light
            case "CTFontMediumUsage":
                return UIFont.Weight.medium
            case "CTFontDemiUsage":
                return UIFont.Weight.semibold
            default:
                return UIFont.Weight.regular
            }
        }
        
        return UIFont.Weight.regular
    }
    
}
