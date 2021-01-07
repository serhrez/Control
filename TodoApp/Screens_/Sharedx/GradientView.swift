//
//  GradientView.swift
//  TodoApp
//
//  Created by sergey on 07.01.2021.
//

import Foundation
import UIKit

class GradientView: UIView {
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        return gradient
    }()
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(gradientLayer)
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        // Supporting black mode
        gradientLayer.colors = [
            UIColor(named: "TABackground")!.withAlphaComponent(0).cgColor,
            UIColor(named: "TABackground")!.withAlphaComponent(1).cgColor
        ]
    }
}
