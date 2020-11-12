//
//  CircleText.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material

class CircleText: UIView {
    let bgColor: UIColor
    let widthHeight: CGFloat
    var label: UILabel!
    
    init(text: String, bgColor: UIColor, widthHeight: CGFloat = 26) {
        self.bgColor = bgColor
        self.widthHeight = widthHeight
        super.init(frame: .zero)
        backgroundColor = .clear
        let containerView = UIView()
        label = UILabel()
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        switch text.count {
        case 1: label.font = .boldSystemFont(ofSize: 16)
        case 2: label.font = .boldSystemFont(ofSize: 14)
        default: label.font = .boldSystemFont(ofSize: 11)

        }
        
        containerView.layout(label).center()
        layout(containerView).edges().width(widthHeight).height(widthHeight)
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
        .init(width: widthHeight, height: widthHeight)
    }
}
