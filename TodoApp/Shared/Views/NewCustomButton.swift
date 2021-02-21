//
//  NewCustomButton.swift
//  TodoApp
//
//  Created by sergey on 26.12.2020.
//

import Foundation
import UIKit

class NewCustomButton: UIButton {
    var animationDuration: TimeInterval = Constants.animationDefaultDuration

    var stateBackgroundColor: ColorState? {
        didSet {
            if let state = stateBackgroundColor {
                self.backgroundColor = state.normal
            }
        }
    }
    var opacityState: OpacityState? {
        didSet {
            if let state = opacityState {
                self.layer.opacity = state.normal
            }
        }
    }
    var pointInsideInsets: UIEdgeInsets?
    override var isHighlighted: Bool {
        didSet {
            if let state = stateBackgroundColor {
                UIView.animate(withDuration: animationDuration) {
                    self.backgroundColor = self.isHighlighted ? state.highlighted : state.normal
                }
            }
            if let state = opacityState {
                UIView.animate(withDuration: animationDuration) {
                    self.layer.opacity = self.isHighlighted ? state.highlighted : state.normal
                }
            }
        }
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let customInsets = pointInsideInsets else {
            return super.point(inside: point, with: event)
        }
        if layer.opacity == 0 || isHidden {
            return false
        }
        return self.bounds.inset(by: customInsets.inverted()).contains(point)
    }
}

extension NewCustomButton {
    struct ColorState {
        var highlighted: UIColor
        var normal: UIColor
    }
    
    struct OpacityState {
        var highlighted: Float
        var normal: Float
    }
}
