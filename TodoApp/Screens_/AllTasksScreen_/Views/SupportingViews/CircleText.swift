//
//  CircleText.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit

class CircleText: UIView {
    let bgColor: UIColor
    
    init(text: String, bgColor: UIColor) {
        self.bgColor = bgColor
        super.init(frame: .zero)
        backgroundColor = .clear
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        
        label.adjustsFontSizeToFitWidth = true
        
        label.minimumScaleFactor = 0.5
        layout(label).edges(top: 1, left: 5, bottom: 1, right: 5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ovalPath = UIBezierPath(ovalIn: rect)
        bgColor.setFill()
        ovalPath.fill()
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 26, height: 26)
    }
}
