//
//  OnboardingPushTransition.swift
//  TodoApp
//
//  Created by sergey on 14.01.2021.
//

import Foundation
import UIKit

class OnboardingPushTransition: NSObject,  UIViewControllerAnimatedTransitioning {
    var transitionDuration: TimeInterval
    
    init(duration: TimeInterval = TimeInterval(UINavigationController.hideShowBarDuration * 2)) {
        self.transitionDuration = duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        transitionContext.containerView.addSubview(toView)
        let initialFrame = toView.frame
            toView.frame = toView.frame.modify(modifyX: { _ in toView.bounds.width })
        UIView.animate(withDuration: transitionDuration, delay: 0.0, options: .curveLinear) {
            toView.frame = initialFrame
            fromView.frame = fromView.frame.modify(modifyX: { _ in -toView.bounds.width })
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}
