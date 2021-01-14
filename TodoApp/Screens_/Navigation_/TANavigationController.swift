//
//  TANavigationController.swift
//  TodoApp
//
//  Created by sergey on 06.01.2021.
//

import Foundation
import UIKit

class TANavigationController: UINavigationController {
    var lastProvider: TATransitionProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension TANavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            let provider = fromVC as? TATransitionProvider
            let transitioning = provider?.pushTransitioning(to: toVC)
            lastProvider = provider
            return transitioning
        }
        if operation == .pop {
            let provider = fromVC as? TATransitionProvider
            let transitioning = provider?.popTransitioning(from: toVC)
            lastProvider = provider
            return transitioning
        }
        lastProvider = nil
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return lastProvider?.interactionController(for: animationController)
    }
}
