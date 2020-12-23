//
//  ProjectDetailsVc.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material
import Typist
import PopMenu

class ProjectDetailsVc: UIViewController {
    private var didAppear: Bool = false
    private let keyboard = Typist()
    private var _oldState: PrScreenState = .empty
    private var state: PrScreenState = .empty {
        didSet {
            changeState(oldState: _oldState, newState: state)
            _oldState = state
        }
    }
    private var project: RlmProject
    init(project: RlmProject) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hex("#F6F6F3")
        topViewSetup()
        toolbarViewSetup()
        projectStartedViewSetup()
        projectNewTaskViewSetup()
        setupKeyboard()
        state = .empty
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        self.newFormView.didAppear()
        self.view.layoutSubviews()
        self.view.layout(tasksToolbar).bottomSafe(30)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) {
            self.top.addShadowFromOutside()
            self.view.layoutSubviews()
        }
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                if self.state.isAddTask && height < 100 { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                if self.state.isAddTask && height < 100 { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .start()

    }
    
    private func changeState(oldState: PrScreenState, newState: PrScreenState) {
//        if newState == .addTask(_)
        var tasksToolBarOpacity: Float = 0
        var projectStartedViewOpacity: Float = 0
        var newFormViewOpacity: Float = 0
        var animationCompletion: (() -> Void)?
        switch (oldState, newState) {
        case (.addTask(_), _):
            newFormView.getFirstResponder()?.resignFirstResponder()
        default: break
        }
        switch (oldState, newState) {
        case (_, .addTask(_)) where !oldState.isAddTask:
            newFormViewOpacity = 1
            animationCompletion = { _ = self.newFormView.becomeFirstResponder() }
        case let (.addTask(_), .addTask(newTask)):
            newFormView.priority = newTask.priority
            newFormView.date = (newTask.date, newTask.reminder, newTask.repeatt)
            newFormView.tags = newTask.tags
            return
        case (_, .list):
            break
        case (_, .empty):
            projectStartedViewOpacity = 1
            tasksToolBarOpacity = 1
        default: break
        }
        func apply() {
            self.tasksToolbar.layer.opacity = tasksToolBarOpacity
            self.projectStartedView.layer.opacity = projectStartedViewOpacity
            self.newFormView.layer.opacity = newFormViewOpacity
        }
        if !didAppear {
            apply()
            animationCompletion?()
        } else {
            UIView.animate(withDuration: 0.5) {
                apply()
            } completion: { _ in
                animationCompletion?()
            }
        }
//        if oldState != newState && newState ==
    }
    
    
    // MARK: - TOP VIEW
    private func topViewSetup() {
        view.layout(top).leading(13).trailing(13).topSafe()
        top.shouldLayoutSubviews = view.layoutSubviews
        newFormView.shouldLayoutSubviews = view.layoutSubviews
    }
    lazy var top = ProjectDetailsTop(
        color: .hex("#FF9900"),
        projectName: "fewfgw",
        projectDescription: "gewgqw",
        icon: .text("🚒"),
        onProjectNameChanged: projectNameChanged,
        onProjectDescriptionChanged: projectDescriptionChanged,
        colorSelection: colorSelection,
        iconSelected: iconClicked,
        shouldAnimate: { [unowned self] in self.didAppear })
    private func projectNameChanged(_ newName: String) {
        
    }
    private func projectDescriptionChanged(_ newDescription: String) {
        
    }
    private func colorSelection(_ sourceView: UIView, _ selectedColor: UIColor) {
        let colorPicker = ColorPicker(viewSource: sourceView, selectedColor: selectedColor, onColorSelection: { print($0) })
        colorPicker.shouldPurposelyAnimateViewBackgroundColor = true
        addChildPresent(colorPicker)
        colorPicker.shouldDismiss = { [weak colorPicker] in
            colorPicker?.addChildDismiss()
        }
    }
    private func iconClicked() {
        
    }
    
    // MARK: - Toolbar VIEW
    private func toolbarViewSetup() {
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(-AllTasksToolbar.estimatedHeight)
        tasksToolbar.onClick = { [weak self] in
            self?.state = .addTask(.init(priority: .none, name: "", description: "", tags: [], date: nil))
        }
    }
    private lazy var tasksToolbar = AllTasksToolbar()
    
    // MARK: - ProjectStarted VIEW
    private func projectStartedViewSetup() {
        view.layout(projectStartedView).center().leading(47).trailing(47)
    }
    private lazy var projectStartedView = ProjectStartedView()
    
    // MARK: - ProjectNewTaskForm VIEW
    private func projectNewTaskViewSetup() {
        view.layout(newFormView).leading().trailing()
        newFormView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    private lazy var newFormView = ProjectNewTaskForm(
        onCalendarClicked: { [unowned self] _ in
            guard var addTask = self.state.addTaskModel else { return }
            let vc = CalendarVc(viewModel: .init(reminder: addTask.reminder, repeat: addTask.repeatt, date: addTask.date), onDone: {
                addTask.date = $0
                addTask.reminder = $1
                addTask.repeatt = $2
                self.state = .addTask(addTask)
            })
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            self.present(nav, animated: true)
        },
        onTagClicked: { [unowned self] sourceView in
            guard var addTask = self.state.addTaskModel else { return }
            var prevFirstResponder = self.getFirstResponder()
            let allTags = Array(RealmProvider.main.realm.objects(RlmTag.self))
                .map { $0.name }
                .filter { !addTask.tags.contains($0) }
            let tagPicker = TagPicker(
                viewSource: sourceView,
                items: allTags,
                shouldPurposelyAnimateViewBackgroundColor: true,
                shouldDismiss: { tagPicker in
                    prevFirstResponder?.becomeFirstResponder()
                    tagPicker.addChildDismiss()
                },
                finished: { result in
                    switch result {
                    case let .existed(tagName), let .new(tagName) where !addTask.tags.contains(tagName):
                        addTask.tags.append(tagName)
                        self.state = .addTask(addTask)
                    default: break
                    }
                })
            self.addChildPresent(tagPicker)
        },
        onPriorityClicked: showPriorityPicker,
        onTagPlusClicked: { [unowned self] in
            guard var addTask = self.state.addTaskModel else { return }
            let tags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in addTask.tags.contains(where: { $0 == tag.name }) }
            self.router.openAllTags(mode: .selection(selected: Array(tags), { selected in
                addTask.tags = ModelFormatt.tagsSorted(tags: selected).map { $0.name }
                self.state = .addTask(addTask)
            }))
        },
        shouldAnimate: { [unowned self] in self.didAppear },
        shouldCreateTask: { [weak self] newTask in
            let rlmTask = RlmTask(name: newTask.name, taskDescription: newTask.description, isDone: false, date: RlmTaskDate(date: newTask.date, reminder: newTask.reminder, repeat: newTask.repeatt), createdAt: Date())
            _ = try! RealmProvider.main.realm.write {
                RealmProvider.main.realm.add(rlmTask)
            }
            self?.state = .list
        })
    
    var didDisappear: () -> Void = { }
    
    // MARK: - Util funcs
    private func getFirstResponder() -> UIView? {
        if let firstResponder = newFormView.getFirstResponder() {
            return firstResponder
        }
        return nil
    }
    
    private func showPriorityPicker(sourceView: UIView) {
//        let task = viewModel.taskToAddComponents
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTaskModel = self?.state.addTaskModel else { return }
                                addTaskModel.priority = .high
                                self?.state = .addTask(addTaskModel)
                            }),
            PopuptodoAction(title: "Medium Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTaskModel = self?.state.addTaskModel else { return }
                                addTaskModel.priority = .medium
                                self?.state = .addTask(addTaskModel)
                            }),
            PopuptodoAction(title: "Low Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTaskModel = self?.state.addTaskModel else { return }
                                addTaskModel.priority = .low
                                self?.state = .addTask(addTaskModel)
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
        UIView.animate(withDuration: 0.2) {
            popMenu.view.layer.opacity = 1
        }
        popMenu.didDismiss = { _ in
            UIView.animate(withDuration: 0.2) {
                popMenu.view.layer.opacity = 0
            } completion: { _ in
                popMenu.willMove(toParent: nil)
                popMenu.view.removeFromSuperview()
                popMenu.removeFromParent()
            }
        }

    }
    deinit {
        didDisappear()
    }
}

extension ProjectDetailsVc {
    enum PrScreenState {
        case empty
        case addTask(ProjectDetailsTaskCreateModel)
        case list
        
        var addTaskModel: ProjectDetailsTaskCreateModel? {
            switch self {
            case let .addTask(task): return task
            default: return nil
            }
        }
        var isAddTask: Bool {
            switch self {
            case .addTask(_): return true
            default: return false
            }
        }
    }
}

extension ProjectDetailsVc: AppNavigationRouterDelegate { }
