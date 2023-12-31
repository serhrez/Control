//
//  AppNavigationRouter.swift
//  TodoApp
//
//  Created by sergey on 10.11.2020.
//

import Foundation
import UIKit
class AppNavigationRouter {
    
    var navigationController: UINavigationController!
    public static let shared = AppNavigationRouter()
    private init() { }
    
    private func pushVc(_ vc: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(vc, animated: true)
    }
            
    func openAllTags(mode: AllTagsVc.Mode) {
        pushVc(AllTagsVc(mode: mode))
    }
    
    func openTime(onDone: @escaping ((hours: Int, minutes: Int)?) -> Void, selected: (hours: Int, minutes: Int)?) {
        pushVc(TimePickerVc(hours: selected?.hours ?? 0, minutes: selected?.minutes ?? 0, onDone: onDone))
    }

    func openIconPicker(onDone: @escaping (String) -> Void) {
        pushVc(IconPickerFullVc(onSelected: onDone))
    }
    
    func openTaskDetails(_ task: RlmTask) {
        pushVc(TaskDetailsVc(viewModel: .init(task: task)))
    }
    
    func openArchive() {
        pushVc(ArchiveVc(viewModel: .init()))
    }
    func openProjectDetails(project: RlmProject, state: ProjectDetailsVc.PrScreenState, isInbox: Bool = false, shouldPopTwo: Bool = false) {
        let projectDetails = ProjectDetailsVc(project: project, state: state, isInbox: isInbox, shouldPopTwo: shouldPopTwo)
        pushVc(projectDetails)
    }
    func openTaskDetails(task: RlmTask) {
        let taskDetailsVc = TaskDetailsVc(viewModel: .init(task: task))
        pushVc(taskDetailsVc)
    }
    func openTagDetails(tag: RlmTag) {
        let tagDetailVc = TagDetailVc(viewModel: .init(tag: tag))
        pushVc(tagDetailVc)
    }
    func openSearch() {
        pushVc(SearchVc())
    }
    func openSettings() {
        pushVc(SettingsVc())
    }
    func openAddProject() {
        pushVc(CreateProjectVc())
    }
    func openPlanned() {
        pushVc(PlannedVc())
    }
    func openPredefinedProject(mode: PredefinedProjectVc.Mode) {
        pushVc(PredefinedProjectVc(mode))
    }
}

extension UIViewController {
    var router: AppNavigationRouter { AppNavigationRouter.shared }
}
