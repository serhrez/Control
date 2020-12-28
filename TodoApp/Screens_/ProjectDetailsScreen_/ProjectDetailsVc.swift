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
import RealmSwift
import RxSwift
import RxCocoa

class ProjectDetailsVc: UIViewController {
    var didAppear: Bool = false
    private let keyboard = Typist()
    private var _oldState: PrScreenState = .emptyOrList 
    private var state: PrScreenState = .emptyOrList {
        didSet {
            changeState(oldState: _oldState, newState: state)
            _oldState = state
        }
    }
    private var project: RlmProject
    private var isInbox: Bool { project.name == "Inbox" }
    private var tokens: [NotificationToken] = []
    private let bag = DisposeBag()
    let trashTextField = TrashTextField()
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
        projectBindingSetup()
        projectStartedViewSetup()
        topViewSetup()
        tasksWithDoneListSetup()
        toolbarViewSetup()
        setupKeyboard()
        projectNewTaskViewSetup()
        self.view.addSubview(trashTextField)
        state = .emptyOrList
        projectPropertiesChanged() // Init state
        applySharedNavigationBarAppearance()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        self.newFormView.didAppear()
        self.view.layoutSubviews()
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
        if case .emptyOrList = newState {
            state = project.tasks.isEmpty ? .empty : .list
            return
        }
        
        // Changing state
        var tasksToolBarOpacity: Float = 0
        var projectStartedViewOpacity: Float = 0
        var newFormViewOpacity: Float = 0
        var tasksWithDoneListOpacity: Float = 0
        var animationCompletion: (() -> Void)?
        // Pre change state
        switch (oldState, newState) {
        case (.addTask(_), _):
            newFormView.getFirstResponder()?.resignFirstResponder()
        default: break
        }
        // Changing state
        switch (oldState, newState) {
        case (.list, .addTask(_)):
            newFormViewOpacity = 1
            tasksWithDoneListOpacity = 1
            animationCompletion = { _ = self.newFormView.becomeFirstResponder() }
        case (_, .addTask(_)) where !oldState.isAddTask:
            newFormViewOpacity = 1
            animationCompletion = { _ = self.newFormView.becomeFirstResponder() }
        case let (.addTask(_), .addTask(newTask)):
            newFormView.priority = newTask.priority
            newFormView.date = (newTask.date, newTask.reminder, newTask.repeatt)
            newFormView.tags = newTask.tags
            return
        case (_, .list):
            tasksWithDoneListOpacity = 1
            tasksToolBarOpacity = 1
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
            self.tasksWithDoneList.layer.opacity = tasksWithDoneListOpacity
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
    
    private func projectPropertiesChanged() {
        topView.color = project.color
        topView.icon = project.icon
    }
    
    private func projectBindingSetup() {
        let token = project.observe(on: .main) { [weak self] change in
            switch change {
            case .change(_, _):
                self?.projectPropertiesChanged()
                break
            case .deleted:
                break
            case let .error(error):
                print(error)
                break
            }
        }
        tokens.append(token)
    }
    
    // MARK: - Navigation Bar
    func setupNavigationBar() {
        addGestureToNavBar() // We add gesture to nav bar in order to check if topView icon was clicked
        navigationItem.rightBarButtonItem = actionsButton
        if isInbox {
            title = "Inbox"
        }
    }
    func addGestureToNavBar() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(navBarClicked))
        navigationController?.navigationBar.addGestureRecognizer(gestureRecognizer)
    }
    @objc func navBarClicked(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: nil)
        print("point: \(point) \(topView)")
        topView.navBarClicked(point: point)
    }
    private lazy var actionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dots"), style: .done, target: self, action: #selector(actionsButtonClicked))
        button.tintColor = .hex("#242424")
        return button
    }()
    
    @objc func actionsButtonClicked() {
        var actions: [PopuptodoAction] = []
        if case .list = state {
            actions += [.init(title: "Delete all done tasks", image: UIImage(named: "plus"), color: .hex("#242424"), didSelect: { _ in
                
            })]
        }
        guard !actions.isEmpty else { return }
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.shouldDismissOnSelection = false
        popMenu.appearance = .appAppearance
        present(popMenu, animated: true)
    }
    
    // MARK: - TOP VIEW
    private func topViewSetup() {
        guard !isInbox else { return }
        view.layout(topView).leading(13).trailing(13).topSafe()
        topView.shouldLayoutSubviews = view.layoutSubviews
        topView.addShadowFromOutside()
    }
    lazy var topView = ProjectDetailsTop(
        color: .hex("#FF9900"),
        projectName: "fewfgw",
        projectDescription: "gewgqw",
        icon: .text("🚒"),
        onProjectNameChanged: { [weak self] newName in
            _ = try! RealmProvider.main.realm.write {
                self?.project.name = newName
            }
        },
        onProjectDescriptionChanged: { [weak self] newDescription in
            _ = try! RealmProvider.main.realm.write {
                self?.project.notes = newDescription
            }
        },
        colorSelection: colorSelection,
        iconSelected: { [weak self] in
            self?.router.openIconPicker(onDone: { selected in
                _ = try! RealmProvider.main.realm.write {
                    self?.project.icon = Icon.text(selected)
                }
            })
        },
        shouldAnimate: { [unowned self] in self.didAppear })
    private func colorSelection(_ sourceView: UIView, _ selectedColor: UIColor) {
        let colorPicker = ColorPicker(
            viewSource: sourceView,
            selectedColor: selectedColor,
            onColorSelection: { [weak self] color, picker in
                _ = try! RealmProvider.main.realm.write {
                    self?.project.color = color
                }
                picker.shouldDismissAnimated()
            })
        colorPicker.shouldPurposelyAnimateViewBackgroundColor = true
        addChildPresent(colorPicker)
        colorPicker.shouldDismiss = { [weak colorPicker] in
            colorPicker?.addChildDismiss()
        }
    }
    
    // MARK: - Toolbar VIEW
    private func toolbarViewSetup() {
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(30)
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
        newFormView.shouldLayoutSubviews = view.layoutSubviews
        newFormView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    private lazy var newFormView = createNewFormView()
        
    // MARK: - TasksWithDoneList VIEW
    private let __tasksSubject = PublishSubject<[RlmTask]>()
    private func tasksWithDoneListSetup() {
        if !isInbox {
            view.layout(tasksWithDoneList).top(topView.anchor.bottom, -10).leading(13).trailing(13).bottom()
            view.bringSubviewToFront(topView)
        } else {
            view.layout(tasksWithDoneList).topSafe().leading(13).trailing(13).bottom()
        }
        tasksWithDoneList.tableView.contentInset = UIEdgeInsets(top: isInbox ? 0 : 13 + 10, left: 0, bottom: 110, right: 0)
        __tasksSubject
            .bind(to: tasksWithDoneList.itemsInput)
            .disposed(by: bag)
        let token = project.tasks.observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: _, insertions: _, modifications: _):
                self.__tasksSubject.onNext(Array(projects.sorted(byKeyPath: "createdAt")))
            case let .initial(projects):
                self.__tasksSubject.onNext(Array(projects.sorted(byKeyPath: "createdAt")))
            case let .error(error):
                print(error)
            }
        }
        tokens.append(token)
    }
    private lazy var tasksWithDoneList = TasksWithDoneList(
        onSelected: { [unowned self] task in
            self.router.openTaskDetails(task)
    })
    
    // MARK: - Util funcs
    func getFirstResponder() -> UIView? {
        if let firstResponder = newFormView.getFirstResponder() {
            return firstResponder
        }
        return nil
    }
    
    var didDisappear: () -> Void = { }

    deinit {
        didDisappear()
    }
}

extension ProjectDetailsVc {
    enum PrScreenState {
        case empty
        case addTask(ProjectDetailsTaskCreateModel)
        case list
        case emptyOrList
        
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

extension ProjectDetailsVc: NewFormViewExt {
    var addTaskModel: ProjectDetailsTaskCreateModel? { state.addTaskModel }
    
    func newAddTask(addTask: ProjectDetailsTaskCreateModel) {
        state = .addTask(addTask)
    }
    
    func shouldCreateTask(task: ProjectDetailsTaskCreateModel) {
        let rlmTask = RlmTask(name: task.name, taskDescription: task.description, priority: task.priority, isDone: false, date: RlmTaskDate(date: task.date, reminder: task.reminder, repeat: task.repeatt), createdAt: Date())
        _ = try! RealmProvider.main.realm.write {
            project.tasks.append(rlmTask)
        }
        state = .emptyOrList
    }
}
