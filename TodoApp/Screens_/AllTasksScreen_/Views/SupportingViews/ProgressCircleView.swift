//
//  ProgressCircleView.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Motion

class OuterCircle: UIView {
    let wrapped: UIView
    private let circle: UIView = UIView()
    private let color: UIColor
    
    init(wrapped: UIView, color: UIColor) {
        self.wrapped = wrapped
        self.color = color
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        layout(wrapped).edges(top: 3, left: 3, bottom: 3, right: 3)
        
        circle.layer.borderWidth = 2
        circle.layer.borderColor = color.cgColor
        layout(circle).edges()
        
        print(self.intrinsicContentSize)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        circle.layer.cornerRadius = rect.height / 2
    }
}

extension OuterCircle {
    static func getCircleWithProgress(widthHeight: CGFloat = 20, percent: CGFloat, color: UIColor, animate: Bool = true) -> OuterCircle {
        return OuterCircle(wrapped: ProgressCircleView(widthHeight: widthHeight, percent: percent, color: color, animate: animate), color: color)
    }
}

class ProgressCircleView: UIView, CAAnimationDelegate {
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: widthHeight, height: widthHeight)
    }
    
    let widthHeight: CGFloat
    let endPercent: CGFloat
    let isAnimated: Bool
    let color: UIColor
    
    init(widthHeight: CGFloat = 20, percent: CGFloat, color: UIColor, animate: Bool = true) {
        self.widthHeight = widthHeight
        self.endPercent = percent
        self.isAnimated = animate
        self.color = color
        super.init(frame: .zero)
        if !isAnimated {
            setupViews()
        }
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func percentToRadian(_ percent: CGFloat) -> CGFloat {
        var angle = -percent * 360
        if angle <= -360 {
            angle += 360
        }
        return angle * CGFloat.pi / 180.0
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if isAnimated {
            setupViews()
        }
    }
    
    var animation: CAPropertyAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        return animation
    }
    
    func setupViews() {
        let path = UIBezierPath(arcCenter: .init(x: intrinsicContentSize.width / 2, y: intrinsicContentSize.height / 2),
                                radius: widthHeight / 4,
                                startAngle: 0,
                                endAngle: percentToRadian(endPercent),
                                clockwise: false)
        
        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = color.cgColor
        sliceLayer.lineWidth = widthHeight / 2
        sliceLayer.strokeEnd = 1
        if isAnimated {
            sliceLayer.add(animation, forKey: animation.keyPath)
        }

        layer.addSublayer(sliceLayer)
    }
}
