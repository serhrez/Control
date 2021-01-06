//
//  FadePushTransition.swift
//  TodoApp
//
//  Created by sergey on 06.01.2021.
//

import Foundation
import UIKit


class FadePushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval
    
    init(duration: TimeInterval = TimeInterval(UINavigationController.hideShowBarDuration * 2)) {
        self.duration = duration
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)!
        transitionContext.containerView.addSubview(toView)
        toView.layer.opacity = 0
        UIView.animate(withDuration: duration) {
            toView.layer.opacity = 1
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }
}
