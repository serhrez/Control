//
//  CustomButton.swift
//  TodoApp
//
//  Created by sergey on 10.11.2020.
//

import Foundation
import UIKit
import Motion

class CustomButton: UIView {
    private let containerView = CustomButtonControl()
    var onClick: () -> Void {
        get { containerView.onClick }
        set { containerView.onClick = newValue }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        bringSubviewToFront(containerView)
    }
    
    func setupViews() {
        layout(containerView).edges()
        clipsToBounds = true
    }
    
    var highlightedColor: UIColor {
        get { containerView.highlightedColor }
        set { containerView.highlightedColor = newValue }
    }
}

fileprivate extension CustomButton {
    class CustomButtonControl: UIControl {
        
        private var animator = UIViewPropertyAnimator()
        
        var highlightedColor = UIColor.blue
        var onClick: () -> Void = { }
                
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupViews() {
            addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
            addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
            layer.opacity = 0.15
        }
        
        @objc private func touchDown() {
            animator.stopAnimation(true)
            backgroundColor = highlightedColor
        }
        
        @objc private func touchUp() {
            onClick()
            animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
                self.backgroundColor = .clear
            })
            animator.startAnimation()
        }
    }

}
