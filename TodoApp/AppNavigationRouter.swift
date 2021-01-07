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
    
    var navigationController: UINavigationController!
    public static let shared = AppNavigationRouter()
    private init() { }
    
    private func pushVc(_ vc: UIViewController, _ transitionType: MotionTransitionAnimationType, animated: Bool = true) {
//        let previousTransitionType = navigationController.motionNavigationTransitionType
//        navigationController.motionNavigationTransitionType = transitionType
//        vc.didDisappear = { [weak self] in
//            self?.navigationController.motionNavigationTransitionType = previousTransitionType
//        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func debugPushVc(_ vc: UIViewController, _ transitionType: MotionTransitionAnimationType = .none) {
        pushVc(vc, transitionType)
    }
    
    func openDateVc(reminder: Reminder?, repeat: Repeat?, date: Date?, onDone: @escaping (Date?, Reminder?, Repeat?) -> Void) {
        pushVc(CalendarVc(viewModel: .init(reminder: reminder, repeat: `repeat`, date: date), onDone: onDone), .autoReverse(presenting: .push(direction: .left)))
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
    
    func openTime(onDone: @escaping (_ hours: Int, _ minutes: Int) -> Void, selected: (hours: Int, minutes: Int)?) {
        pushVc(TimePickerVc(hours: selected?.hours ?? 0, minutes: selected?.minutes ?? 0, onDone: onDone), .autoReverse(presenting: .push(direction: .left)))
    }

    func openIconPicker(onDone: @escaping (String) -> Void) {
        pushVc(IconPickerFullVc(onSelected: onDone), .autoReverse(presenting: .push(direction: .left)))
    }
    
    func openTaskDetails(_ task: RlmTask) {
        pushVc(TaskDetailsVc(viewModel: .init(task: task)), .autoReverse(presenting: .push(direction: .left)))
    }
    
    func openArchive() {
        pushVc(ArchiveVc(viewModel: .init()), .auto)
    }
}

extension UIViewController {
    var router: AppNavigationRouter { AppNavigationRouter.shared }
}
