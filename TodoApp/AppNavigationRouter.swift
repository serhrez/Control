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
    
    func openAllTags(mode: AllTagsVc.Mode) {
        pushVc(AllTagsVc(mode: mode), .autoReverse(presenting: .push(direction: .left)))
    }
    
    func openReminder(onDone: @escaping (Reminder?) -> Void, selected: Reminder?) {
        pushVc(Selection1Vc.reminderVc(onDone: onDone, selected: selected), .autoReverse(presenting: .push(direction: .left)))
    }
    
    func openRepeat(onDone: @escaping (Repeat?) -> Void, selected: Repeat?) {
        pushVc(Selection1Vc.repeatVc(onDone: onDone, selected: selected), .autoReverse(presenting: .push(direction: .left)))
    }

}

extension UIViewController {
    var router: AppNavigationRouter { AppNavigationRouter.shared }
}
