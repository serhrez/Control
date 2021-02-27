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
    var transformState: State<CGAffineTransform>? {
        didSet {
            if let state = transformState {
                self.transform = state.normal
            }
        }
    }
    var stateBackgroundColor: State<UIColor>? {
        didSet {
            if let state = stateBackgroundColor {
                self.backgroundColor = state.normal
            }
        }
    }
    var opacityState: State<Float>? {
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
                apply({ self.backgroundColor = $0 }, state: state)
            }
            if let state = opacityState {
                apply({ self.layer.opacity = $0 }, state: state)
            }
            if let state = transformState {
                apply({ self.transform = $0 }, state: state)
            }
        }
    }
    func apply<T>(_ applyFunction: @escaping (T) -> Void, state: State<T>) {
        UIView.animate(withDuration: animationDuration) {
            applyFunction(self.isHighlighted ? state.highlighted : state.normal)
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
    struct State<T> {
        var highlighted: T
        var normal: T
    }
}
