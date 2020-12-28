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
    
    init(wrapped: UIView) {
        self.wrapped = wrapped
        super.init(frame: .zero)
        setupViews()
    }
    
    func configure(color: UIColor) {
        circle.layer.borderColor = color.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        layout(wrapped).edges(top: 3.5, left: 3.5, bottom: 3.5, right: 3.5)
        
        circle.layer.borderWidth = 2
        layout(circle).edges()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        circle.layer.cornerRadius = rect.height / 2
    }
}
