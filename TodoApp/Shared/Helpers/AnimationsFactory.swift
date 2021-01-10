//
//  AnimationsManager.swift
//  TodoApp
//
//  Created by sergey on 10.01.2021.
//

import Foundation
import UIKit

enum AnimationsFactory {
    
    static func jiggleWithMove(_ view: UIView, duration: TimeInterval = Constants.animationDefaultDuration) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                    view.transform = CGAffineTransform(rotationAngle: -.pi / 8).concatenating(.init(translationX: -3, y: 1))
                }
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75) {
                    view.transform = CGAffineTransform(rotationAngle: +.pi / 8).concatenating(.init(translationX: 3, y: 1))
                }
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                    view.transform = CGAffineTransform.identity
                }
            }, completion: nil)
        }
        return animator
//        return UIViewPropertyAnimator
    }
}
