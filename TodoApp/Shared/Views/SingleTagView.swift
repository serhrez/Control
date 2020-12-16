//
//  SingleTagView.swift
//  TodoApp
//
//  Created by sergey on 16.12.2020.
//

import Foundation
import UIKit
import Material

class ThreeDotsTagView: UIView {
    private var width: CGFloat { 20 }
    private var height: CGFloat { 16 }
    private var dotSize: CGFloat { 2 }
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.hex("#00CE15").withAlphaComponent(0.1)
        widthAnchor.constraint(equalToConstant: 20).isActive = true
        heightAnchor.constraint(equalToConstant: 16).isActive = true
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        layer.addSublayer(getDotLayer(offsetX: 0))
        layer.addSublayer(getDotLayer(offsetX: -dotSize * 2))
        layer.addSublayer(getDotLayer(offsetX: dotSize * 2))

    }
    
    func getDotLayer(offsetX: CGFloat) -> CALayer {
        let layer = CALayer()
        layer.width = 2
        layer.height = 2
        layer.cornerRadius = 1
        layer.backgroundColor = UIColor.hex("#00CE15").cgColor
        layer.frame = .init(x: width / 2 - dotSize / 2 + offsetX, y: height / 2 - dotSize / 2, width: dotSize, height: dotSize)
        return layer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class SingleTagView: UIView {
    let label = UILabel(frame: .zero)
    var text: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        layout(label).leading(8).trailing(8).centerY()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        backgroundColor = UIColor.hex("#00CE15").withAlphaComponent(0.1)
        label.textColor = .hex("#00CE15")
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        self.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
