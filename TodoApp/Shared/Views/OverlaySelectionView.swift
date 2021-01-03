//
//  OverlayView.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit

class OverlaySelectionView: UIView {
    var selectedBackgroundColor = UIColor.blue
    private var animator: UIViewPropertyAnimator?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.opacity = 0.15
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool = true) {
        if highlighted {
            animator?.stopAnimation(true)
            self.backgroundColor = selectedBackgroundColor
        } else {
            if animated {
                animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut, animations: {
                    self.backgroundColor = .clear
                })
                animator?.startAnimation()
            } else {
                self.backgroundColor = .clear
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        return hitView == self ? nil : hitView
    }
}

