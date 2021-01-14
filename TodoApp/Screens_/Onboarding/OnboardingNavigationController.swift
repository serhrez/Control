//
//  OnboardingNavigationController.swift
//  TodoApp
//
//  Created by sergey on 14.01.2021.
//

import Foundation
import UIKit

class OnboardingNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension OnboardingNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return OnboardingPushTransition()
        }
        return nil
    }
}
