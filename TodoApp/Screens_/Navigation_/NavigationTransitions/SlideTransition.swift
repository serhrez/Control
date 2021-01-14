//
//  SlideTransition.swift
//  TodoApp
//
//  Created by sergey on 06.01.2021.
//

import Foundation
import UIKit

class SlidePushTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    var transitionDuration: TimeInterval
    var isInteractive: Bool = false
    
    init(duration: TimeInterval = TimeInterval(UINavigationController.hideShowBarDuration * 2)) {
        self.transitionDuration = duration
        super.init()
        self.completionSpeed = CGFloat(duration * 0.7)
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }
    
    func handlePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = abs(gesture.translation(in: gesture.view).x / gesture.view!.bounds.width)
        switch gesture.state {
        case .changed:
            update(percent)
        case .ended, .cancelled:
            if percent > 0.5 && gesture.state != .cancelled {
                finish()
            } else {
                cancel()
            }
        default: break
        }
    }

    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)!
        transitionContext.containerView.addSubview(toView)
        let initialFrame = toView.frame
            toView.frame = toView.frame.modify(modifyX: { _ in -toView.bounds.width })
        UIView.animate(withDuration: transitionDuration, delay: 0.0, options: .curveLinear) {
            toView.frame = initialFrame
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}

class SlidePopTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    var transitionDuration: TimeInterval
    var isInteractive: Bool = false
    
    init(duration: TimeInterval = TimeInterval(UINavigationController.hideShowBarDuration * 2)) {
        self.transitionDuration = duration
        super.init()
        self.completionSpeed = CGFloat(duration * 0.7)
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        toView.alpha = 0.7
        UIView.animate(withDuration: transitionDuration, delay: 0.0, options: .curveLinear) {
            toView.alpha = 1
            fromView.frame = fromView.frame.modify(modifyX: { _ in -fromView.frame.bounds.width })
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func handlePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = abs(gesture.translation(in: gesture.view).x / gesture.view!.bounds.width)
        switch gesture.state {
        case .changed:
            update(percent)
        case .ended, .cancelled:
            if percent > 0.5 && gesture.state != .cancelled {
                finish()
            } else {
                cancel()
            }
        default: break
        }
    }

}
