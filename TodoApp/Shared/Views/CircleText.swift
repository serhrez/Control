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
    var bgColor: UIColor? {
        didSet {
            let previousBgColor = self.bgColor
            if previousBgColor != bgColor {
                setNeedsDisplay()
            }
        }
    }
    var text: String? {
        set {
            guard let text = newValue else { return }
            label.text = text
            switch text.count {
            case 1: label.font = .boldSystemFont(ofSize: 16)
            case 2: label.font = .boldSystemFont(ofSize: 14)
            default: label.font = .boldSystemFont(ofSize: 11)
            }
        }
        get { label.text }
    }
    
    private let widthHeight: CGFloat
    private var label: UILabel!
    
    init(widthHeight: CGFloat = 26) {
        self.widthHeight = widthHeight
        super.init(frame: .zero)
        backgroundColor = .clear
        let containerView = UIView()
        label = UILabel()
        label.textColor = UIColor(named: "TAAltBackground")!
        label.textAlignment = .center
        
        containerView.layout(label).center()
        layout(containerView).edges().width(widthHeight).height(widthHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let bgColor = bgColor else { return }
        let ovalPath = UIBezierPath(ovalIn: rect)
        bgColor.setFill()
        ovalPath.fill()
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: widthHeight, height: widthHeight)
    }
}
