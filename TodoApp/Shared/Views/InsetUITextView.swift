//
//  InsetUITextView.swift
//  TodoApp
//
//  Created by sergey on 24.11.2020.
//

import Foundation
import UIKit

class InsetUITextView: UITextView {
    override func alignmentRect(forFrame frame: CGRect) -> CGRect {
        
        return super.alignmentRect(forFrame: frame)
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 200, height: 30)
    }
}
