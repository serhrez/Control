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
            UIColor(named: "TABackground")!.withAlphaComponent(0.7).cgColor
        ]
    }
}

class GradientView2: UIView {
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = self.startPoint
        gradient.endPoint = self.endPoint
        gradient.locations = locations
        return gradient
    }()
    let startPoint: CGPoint
    let endPoint: CGPoint
    let colors: [UIColor]
    let locations: [NSNumber]?
    
    required init(startPoint: CGPoint, endPoint: CGPoint, colors: [UIColor], locations: [NSNumber]? = nil) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.colors = colors
        self.locations = locations
        super.init(frame: .zero)
        layer.addSublayer(gradientLayer)
        isUserInteractionEnabled = false
    }
    
    convenience init(colors: [UIColor], direction: Direction, locations: [NSNumber]? = nil) {
        self.init(startPoint: direction == .vertical ? .init(x: 0.5, y: 0) : .init(x: 0, y: 0.5), endPoint: direction == .vertical ? .init(x: 0.5, y: 1) : .init(x: 1, y: 0.5), colors: colors, locations: locations)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func animateLocations() {
        var fromLocations: [NSNumber] = []
        var toLocations: [NSNumber] = []
        if locations != nil {
            fromLocations = locations!
        } else
        if colors.count == 2 {
            fromLocations = [0, 100]
            toLocations = [99, 100]
        } else
        if colors.count == 3 {
            fromLocations = [0, 50, 100]
            toLocations = [98,99,100]
        } else
        if colors.count == 4 {
            fromLocations = [0, 33, 66, 100]
            toLocations = [97,98,99,100]
        }
        let anim2 = CABasicAnimation(keyPath: "colors")
        anim2.fromValue = colors.map { $0.cgColor }
        anim2.toValue = Array(colors.map { $0.cgColor }.reversed())
        anim2.duration = Constants.animationDefaultDuration * 4
        anim2.repeatCount = .infinity
        anim2.autoreverses = true
        gradientLayer.add(anim2, forKey: nil)
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        // Supporting black mode
        gradientLayer.colors = colors.map { $0.cgColor }
    }
    enum Direction {
        case vertical
        case horizontal
    }
}
