//
//  TATransitionProvider.swift
//  TodoApp
//
//  Created by sergey on 06.01.2021.
//

import Foundation
import UIKit

protocol TATransitionProvider {
    func pushTransitioning(from vc: UIViewController) -> UIViewControllerAnimatedTransitioning?
    func popTransitioning(from vc: UIViewController) -> UIViewControllerAnimatedTransitioning?
    func interactionController(for animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}
