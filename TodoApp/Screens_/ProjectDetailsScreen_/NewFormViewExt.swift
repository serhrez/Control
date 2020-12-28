//
//  NewFormViewExt.swift
//  TodoApp
//
//  Created by sergey on 28.12.2020.
//

import Foundation
import UIKit
import Material
import Typist
import PopMenu
 
protocol NewFormViewExt: UIViewController {
    var addTaskModel: ProjectDetailsTaskCreateModel? { get }
    var didAppear: Bool { get }
    var trashTextField: TrashTextField { get }
    func getFirstResponder() -> UIView?
    func newAddTask(addTask: ProjectDetailsTaskCreateModel)
    func shouldCreateTask(task: ProjectDetailsTaskCreateModel)
}

extension NewFormViewExt {
    func createNewFormView() -> ProjectNewTaskForm {
        ProjectNewTaskForm(
            onCalendarClicked: { [unowned self] _ in
                guard var addTask = addTaskModel else { return }
                let vc = CalendarVc(viewModel: .init(reminder: addTask.reminder, repeat: addTask.repeatt, date: addTask.date), onDone: {
                    addTask.date = $0
                    addTask.reminder = $1
                    addTask.repeatt = $2
                    newAddTask(addTask: addTask)
                })
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .overFullScreen
                self.present(nav, animated: true)
            },
            onTagClicked: { [unowned self] sourceView in
                guard var addTask = addTaskModel else { return }
                let prevFirstResponder = self.getFirstResponder()
                let allTags = Array(RealmProvider.main.realm.objects(RlmTag.self))
                    .map { $0.name }
                    .filter { !addTask.tags.contains($0) }
                let tagPicker = TagPicker(
                    viewSource: sourceView,
                    items: allTags,
                    shouldPurposelyAnimateViewBackgroundColor: true,
                    shouldDismiss: { tagPicker in
                        tagPicker.addChildDismiss()
                        prevFirstResponder?.becomeFirstResponder()
                    },
                    finished: { result in
                        switch result {
                        case let .existed(tagName) where !addTask.tags.contains(tagName):
                            addTask.tags.append(tagName)
                            newAddTask(addTask: addTask)
                        case let .new(tagName) where !addTask.tags.contains(tagName):
                            addTask.tags.append(tagName)
                            newAddTask(addTask: addTask)
                            if !RealmProvider.main.realm.objects(RlmTag.self).contains(where: { $0.name == tagName }) {
                                _ = try! RealmProvider.main.realm.write {
                                    RealmProvider.main.realm.add(RlmTag(name: tagName))
                                }
                            }
                        default: break
                        }
                    })
                self.addChildPresent(tagPicker)
                self.trashTextField.becomeFirstResponder()
            },
            onPriorityClicked: showPriorityPicker,
            onTagPlusClicked: { [unowned self] in
                guard var addTask = addTaskModel else { return }
                let tags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in addTask.tags.contains(where: { $0 == tag.name }) }
                self.router.openAllTags(mode: .selection(selected: Array(tags), { selected in
                    addTask.tags = ModelFormatt.tagsSorted(tags: selected).map { $0.name }
                    newAddTask(addTask: addTask)
                }))
            },
            shouldAnimate: { [unowned self] in self.didAppear },
            shouldCreateTask: shouldCreateTask)
    }
    
    func showPriorityPicker(sourceView: UIView) {
        let prevFirstResponder = self.getFirstResponder()
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTaskModel = self?.addTaskModel else { return }
                                addTaskModel.priority = .high
                                self?.newAddTask(addTask: addTaskModel)
                            }),
            PopuptodoAction(title: "Medium Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.addTaskModel else { return }
                                addTask.priority = .medium
                                self?.newAddTask(addTask: addTask)
                            }),
            PopuptodoAction(title: "Low Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.addTaskModel else { return }
                                addTask.priority = .low
                                self?.newAddTask(addTask: addTask)
                            })
        ]
        actions[0].imageTintColor = .hex("#EF4439")
        actions[1].imageTintColor = .hex("#FF9900")
        actions[2].imageTintColor = .hex("#447BFE")
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: sourceView, actions: actions)
        popMenu.appearance = .appAppearance
        popMenu.isCrutchySolution1 = true
        popMenu.view.layer.opacity = 0
        addChildPresent(popMenu)
        trashTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            popMenu.view.layer.opacity = 1
        }
        popMenu.didDismiss = { [weak popMenu] _ in
            UIView.animate(withDuration: 0.2) {
                popMenu?.view.layer.opacity = 0
            } completion: { _ in
                popMenu?.addChildDismiss()
                prevFirstResponder?.becomeFirstResponder()
            }
        }
    }

}
