//
//  OuterCircle.swift
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
        layout(wrapped).edges(top: 3.5, left: 3.5, bottom: 3.5, right: 3.5)
        
        circle.layer.borderWidth = 2
        circle.layer.borderColor = color.cgColor
        layout(circle).edges()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        circle.layer.cornerRadius = rect.height / 2
    }
}

extension OuterCircle {
    static func getCircleWithProgress(widthHeight: CGFloat = 19, percent: CGFloat, color: UIColor, animate: Bool = true) -> OuterCircle {
        return OuterCircle(wrapped: ProgressCircleView(widthHeight: widthHeight, percent: percent, color: color, animate: animate), color: color)
    }
}
