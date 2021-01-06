//
//  PopMenuPresentAnimationController.swift
//  PopMenu
//
//  Created by Cali Castle on 4/12/18.
//  Copyright © 2018 Cali Castle. All rights reserved.
//

import UIKit

final public class PopMenuPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// Source view's frame.
    private let sourceFrame: CGRect?
    
    /// Initializer with source view's frame.
    init(sourceFrame: CGRect?) {
        self.sourceFrame = sourceFrame
    }
    
    /// Duration of the transition.
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    /// Animate PopMenuViewController custom transition.
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let menuViewController = transitionContext.viewController(forKey: .to) as? PopMenuViewController else { return }
        
        let containerView = transitionContext.containerView
        let view = menuViewController.view!
        containerView.addSubview(view)
        
        menuViewController.containerView.layoutIfNeeded()
        let contentFrame = menuViewController.contentFrame
        menuViewController.contentLeftConstraint.constant = contentFrame.origin.x
        menuViewController.contentTopConstraint.constant = contentFrame.origin.y
        menuViewController.contentWidthConstraint.constant = contentFrame.size.width
        menuViewController.contentHeightConstraint.constant = contentFrame.size.height
        
        menuViewController.containerView.layoutIfNeeded()
        
        prepareAnimation(menuViewController)
        
        let animationDuration = transitionDuration(using: transitionContext)
        let animations = {
            self.animate(menuViewController)
        }
        UIView.animate(withDuration: animationDuration, delay: 0, animations: animations) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    /// States before animation.
    var initialPosition: CGPoint = .zero
    fileprivate func prepareAnimation(_ viewController: PopMenuViewController) {
        viewController.containerView.alpha = 0
        viewController.backgroundView.alpha = 0
    }
    
    /// Run the animation.
    fileprivate func animate(_ viewController: PopMenuViewController) {
        viewController.containerView.alpha = 1
        viewController.backgroundView.alpha = 1
    }
    
}
