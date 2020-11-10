//
//  AppNavigationRouter.swift
//  TodoApp
//
//  Created by sergey on 10.11.2020.
//

import Foundation
import UIKit
import Motion
import Material

protocol AppNavigationRouterDelegate: AnyObject {
    var didDisappear: () -> Void { get set }
}

class AppNavigationRouter {
    
    var navigationController: AppNavigationController!
    public static let shared = AppNavigationRouter()
    private init() { }
    
    private func pushVc(_ vc: UIViewController & AppNavigationRouterDelegate, _ transitionType: MotionTransitionAnimationType, animated: Bool = true) {
        let previousTransitionType = navigationController.motionNavigationTransitionType
        navigationController.motionNavigationTransitionType = transitionType
        vc.didDisappear = { [weak self] in
            self?.navigationController.motionNavigationTransitionType = previousTransitionType
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func debugPushVc(_ vc: UIViewController & AppNavigationRouterDelegate, _ transitionType: MotionTransitionAnimationType = .none) {
        pushVc(vc, transitionType)
    }
}

extension UIViewController {
    var router: AppNavigationRouter { AppNavigationRouter.shared }
}
