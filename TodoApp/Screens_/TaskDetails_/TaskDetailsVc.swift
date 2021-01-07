//
//  TaskDetailsVc.swift
//  TodoApp
//
//  Created by sergey on 18.11.2020.
//

import Foundation
import UIKit
import Material
import PopMenu
import ResizingTokenField
import AttributedLib
import RxSwift
import RxDataSources
import SwipeCellKit
import Typist
import SnapKit

final class TaskDetailsVc: UIViewController {
    private let viewModel: TaskDetailsVcVm
    private let bag = DisposeBag()
    private lazy var subtasksTable: UITableView = {
        let collectionView = UITableView(frame: .zero)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private lazy var actionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dots"), style: .done, target: self, action: #selector(actionsButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()
    private let keyboard = Typist()
    private var isCurrentlyShown = false
    private var shouldUpdateTagsOnShown = false
    private var wasAlreadyShown: Bool = false

    init(viewModel: TaskDetailsVcVm) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupViewModelBinding()
        setupBindings()
        updateTags()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        if shouldUpdateTagsOnShown {
            updateTags()
            shouldUpdateTagsOnShown = false
        }
        isCurrentlyShown = true
        wasAlreadyShown = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isCurrentlyShown = false
    }
    
    private func setupViews() {
        setupTokenField()
        view.backgroundColor = UIColor(named: "TABackground")
        setupNavigationBar()
        
        setupContainerView()
        setupTableView()
        setupKeyboard()
    }
    var testx: CGRect?
    var subtasksAddCellReference: SubtaskAddCell?
    private func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            //.toolbar(scrollView: collectionView)
            .on(event: .willChangeFrame) { [weak self] options in
                guard let self = self else { return }
                let height = options.endFrame.intersection(self.scrollView.convert(self.scrollView.bounds, to: nil)).height
                self.testx = options.endFrame
                if previousHeight == height { return }
                previousHeight = height
                UIView.animate(withDuration: 0.5) {
                    self.scrollView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
                }
            }
            .on(event: .willHide) { [weak self] options in
                guard let self = self else { return }
                let height = options.endFrame.intersection(self.scrollView.convert(self.scrollView.bounds, to: nil)).height
                self.testx = options.endFrame
                if previousHeight == height { return }
                previousHeight = height
                UIView.animate(withDuration: 0.5) {
                    self.scrollView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
                }
            }
            .start()
    }
    
    private func setupBindings() {
        checkboxh1.onSelected = { [weak self] in
            self?.viewModel.toggleDone()
        }
        tokenField.onPlusButtonClicked = { [weak self] in
            guard let self = self else { return }
            self.addTagsSelected(action: PopuptodoAction())
        }
    }
    
    private func setupTableView() {
        subtasksTable.register(SubtaskCell.self, forCellReuseIdentifier: SubtaskCell.reuseIdentifier)
        subtasksTable.register(SubtaskAddCell.self, forCellReuseIdentifier: SubtaskAddCell.reuseIdentifier)
        subtasksTable.delegate = self
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimSection<TaskDetailsVcVm.Model>> { [weak self] (data, tableView, indexPath, model) -> UITableViewCell in
            switch model {
            case .addSubtask:
                let cell = tableView.dequeueReusableCell(withIdentifier: SubtaskAddCell.reuseIdentifier, for: indexPath) as! SubtaskAddCell
                cell.subtaskCreated = { name in
                    self?.viewModel.createSubtask(with: name)
                }
                if self?.isCurrentlyShown ?? false {
                    cell.becomeFirstResponder()
                }
                return cell
            case let .subtask(subtask):
                let cell = tableView.dequeueReusableCell(withIdentifier: SubtaskCell.reuseIdentifier, for: indexPath) as! SubtaskCell
                cell.configure(name: subtask.name, isDone: subtask.isDone)
                cell.delegate = self
                cell.onSelected = {
                    self?.viewModel.toggleDoneSubtask(subtask: subtask, isDone: $0)
                }
                return cell
            }
        }
        viewModel.reloadSubtaskCells = { [weak self] mods in
            self?.subtasksTable.reloadRows(at: mods.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        var wasAlreadyLoaded = false
        viewModel.subtasksUpdate
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                let itemsCount = self.viewModel.subtasksModels[0].items.count
                let height = CGFloat(itemsCount * SubtaskCell.height)// + (itemsCount > 0 ? 44 : 0))
                self.subtasksTable.snp.remakeConstraints { make in
                    make.height.equalTo(height)
                }
                if wasAlreadyLoaded {
                    self.layoutAnimate()
                }
                wasAlreadyLoaded = true
            })
            .bind(to: subtasksTable.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    private func subtaskCreated(with name: String) {
        self.viewModel.createSubtask(with: name)
    }
    
    private func setupViewModelBinding() {
        self.taskNameh1.text = viewModel.task.name
        self.setTaskDescription(viewModel.task.taskDescription)
        viewModel.shouldEnableTaskDescription = { [weak self] in
            self?.explicitlyEnableTaskDescription()
        }
        viewModel.taskObservable
            .subscribe(onNext: { [weak self] task in
                guard let self = self else { return }
                self.checkboxh1.configure(isChecked: task.isDone)
                self.checkboxh1.configure(priority: task.priority)
                self.updateLabels(taskDate: task.date)
            })
            .disposed(by: bag)
        viewModel.tagsObservable
            .subscribe(onNext: { [weak self] tags in
                guard let self = self else { return }
                if self.isCurrentlyShown || !self.wasAlreadyShown {
                    self.updateTags()
                } else {
                    self.shouldUpdateTagsOnShown = true
                }
            })
            .disposed(by: bag)
    }
    var __previousHeight: CGFloat?
    func layoutAnimate() {
        setSpacings()
        if wasAlreadyShown {
            UIView.animate(withDuration: 0.5) {
                self.view.layoutSubviews()
                self.containerStack.layoutSubviews()
            }
        }
    }
    
    func setTaskDescription(_ taskDescription: String) {
        defer {
            layoutAnimate()
        }
        if !self.taskDescription.text.isEmpty {
            return
        }
        guard !taskDescription.isEmpty else {
            self.taskDescription.isHidden = true
            return
        }
        self.taskDescription.isHidden = false
        self.taskDescription.text = taskDescription
    }
    
    func explicitlyEnableTaskDescription() {
        self.taskDescription.isHidden = false
        layoutAnimate()
        taskDescription.becomeFirstResponder()
    }
    
    func updateTags() {
        defer {
            layoutAnimate()
        }
        guard !(viewModel.task.tags.isEmpty) else {
            self.tokenField.isHidden = true
            self.tokenField.removeAllTokens()
            return
        }
        self.tokenField.isHidden = false
        let old = tokenField.tokens as? [ResizingToken]
        let newTags = ModelFormatt.tagsSorted(tags: Array(viewModel.task.tags)).map { ResizingToken(title: $0.name) }
        tokenField.deepdiff(old: old ?? [], new: newTags)
    }
    
    func updateLabels(taskDate: RlmTaskDate?) {
        if let date = taskDate?.date {
            dateDetailLabel.isHidden = false
            dateDetailLabel.configure(with: DateFormatter.str(from: date))
        } else {
            dateDetailLabel.isHidden = true
        }
        if let reminder = taskDate?.reminder {
            reminderDetailLabel.isHidden = false
            reminderDetailLabel.configure(with: reminder.description)
        } else {
            reminderDetailLabel.isHidden = true
        }
        if let repeatt = taskDate?.repeat {
            repeatDetailLabel.isHidden = false
            repeatDetailLabel.configure(with: repeatt.description)
        } else {
            repeatDetailLabel.isHidden = true
        }
        layoutAnimate()
    }
        
    let containerView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "containerView"
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let containerStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.accessibilityIdentifier = "containerStack"
        stack.axis = .vertical
        return stack
    }()
    
    private let horizontal1: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.accessibilityIdentifier = "horizontal1"
        stack.spacing = 13
        stack.alignment = .top
        return stack
    }()
    private let checkboxh1: CheckboxView = {
        let view = CheckboxView()
        view.tint = .hex("#00CE15")
        view.accessibilityIdentifier = "checkboxh1"
        return view
    }()
    
    private lazy var checkboxh1Container: UIView = {
        let view = UIView()
        view.layout(checkboxh1).leading().trailing().centerY()
        view.snp.makeConstraints { make in
            make.height.equalTo(taskNameh1.textField.font?.lineHeight ?? 24)
        }
        return view
    }()
    private lazy var taskNameh1: MyGrowingTextView = {
        let taskLabel = MyGrowingTextView(placeholderText: "Call to John Wick?", scrollBehavior: .noScroll)
        taskLabel.textField.font = .systemFont(ofSize: 20, weight: .medium)
        taskLabel.accessibilityIdentifier = "taskNameh1"
        taskLabel.placeholderAttrs = Attributes().font(.systemFont(ofSize: 20, weight: .medium)).foreground(color: UIColor(named: "TASubElement")!)
        taskLabel.textFieldAttrs = Attributes().font(.systemFont(ofSize: 20, weight: .medium)).foreground(color: UIColor(named: "TAHeading")!)
        taskLabel.growingTextFieldDelegate = self
        return taskLabel
    }()
    
    private lazy var taskDescription: MyGrowingTextView = {
        let description = MyGrowingTextView(placeholderText: "Enter description", scrollBehavior: .noScroll)
        description.accessibilityIdentifier = "taskDescription"
        let attributes: Attributes = Attributes().lineSpacing(5).foreground(color: UIColor(named: "TASubElement")!).font(.systemFont(ofSize: 16, weight: .regular))
        description.placeholderAttrs = attributes
        description.textFieldAttrs = attributes
        description.growingTextFieldDelegate = self
        return description
    }()
    
    private let tokenField: ResizingTokenField = ResizingTokenField()
        
    private let stackDateDetail: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.accessibilityIdentifier = "stackDateDetail"
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        return stack
    }()
    
    private let dateDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.accessibilityIdentifier = "dateDetailLabel"
        view.setImage(image: UIImage(named: "alarm")?.resize(toWidth: 14))
        view.isHidden = true
        return view
    }()
    
    private let datesStackSeparator: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "datesStackSeparator"
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return view
    }()
    
    private let stackReminderRepeat: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.spacing = 6
        stack.layoutMargins = .init(top: 6, left: 0, bottom: 0, right: 0)
        stack.accessibilityIdentifier = "stackReminderRepeat"
        return stack
    }()
        
    private let reminderDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "bell")?.resize(toWidth: 16))
        view.accessibilityIdentifier = "reminderDetailLabel"
        view.isHidden = true
        return view
    }()
    
    private let repeatDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "repeat")?.resize(toWidth: 13))
        view.isHidden = true
        view.accessibilityIdentifier = "repeatDetailLabel"
        return view
    }()
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.accessibilityIdentifier = "scrollView"
        view.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        return view
    }()
    
    func setupTokenField() {
        tokenField.delegate = self
        tokenField.itemSpacing = 4
        tokenField.allowDeletionTags = false
        tokenField.hideLabel(animated: false)
        tokenField.font = .systemFont(ofSize: 15, weight: .semibold)
        tokenField.preferredTextFieldReturnKeyType = .done
        tokenField.heightConstraint?.isActive = false
        tokenField.contentInsets = .zero
        tokenField.isHidden = true
        
        tokenField.snp.makeConstraints { make in
            make.height.equalTo(tokenField.itemHeight)
        }
    }
    
    private func setupContainerView() {
        view.layout(containerView).leading(13).trailing(13).topSafe(30)
            .bottomSafe(30) { _, _ -> LayoutRelation in
            return .lessThanOrEqual
        }
        containerView.layout(scrollView).edges()
        scrollView.layout(containerStack).leading(26).trailing(26).top(23)
        scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: containerStack.heightAnchor, constant: 23 + 23).isActive = true // 23 top + 23 bottom
        let containerHeight = containerView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        containerHeight.priority = .init(749)
        containerHeight.isActive = true
        scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        containerStack.isUserInteractionEnabled = true
        horizontal1.isUserInteractionEnabled = true
        horizontal1.addArrangedSubview(checkboxh1Container)
        horizontal1.addArrangedSubview(taskNameh1)
        containerStack.addArrangedSubview(horizontal1)
        let taskDescriptionHeight = self.taskDescription.heightAnchor.constraint(equalToConstant: self.taskDescription.textField.font?.lineHeight ?? 20)
        taskDescriptionHeight.isActive = true
        taskDescription.shouldSetHeight = { [weak self] in
            taskDescriptionHeight.constant = $0
            self?.layoutAnimate()
        }
        
        let taskNameHeight = taskNameh1.heightAnchor.constraint(equalToConstant: 20)
        taskNameHeight.isActive = true
        taskNameh1.shouldSetHeight = { [weak self] newHeight in
            taskNameHeight.constant = newHeight
            self?.layoutAnimate()
        }
        containerStack.addArrangedSubview(taskDescription)
        containerStack.addArrangedSubview(tokenField)
        containerStack.addArrangedSubview(subtasksTable)
        stackDateDetail.addArrangedSubview(dateDetailLabel)
        stackDateDetail.addArrangedSubview(UIView()) // empty view
        
        containerStack.addArrangedSubview(stackDateDetail)
        stackReminderRepeat.addArrangedSubview(reminderDetailLabel)
        stackReminderRepeat.addArrangedSubview(repeatDetailLabel)
        stackReminderRepeat.addArrangedSubview(UIView()) // empty view
        containerStack.addArrangedSubview(datesStackSeparator) // empty view
        containerStack.addArrangedSubview(stackReminderRepeat)
    }
    
    func setSpacings() {
        let task = viewModel.task
        let spacingAfterHorizontal1 = !taskDescription.isHidden || !task.tags.isEmpty || !task.subtask.isEmpty || task.date?.date != nil || task.date?.reminder != nil || task.date?.repeat != nil
        containerStack.setCustomSpacing(spacingAfterHorizontal1 ? 16 : 0, after: horizontal1)
        let spacingAfterTaskDescription = !task.tags.isEmpty || !task.subtask.isEmpty || task.date?.date != nil || task.date?.reminder != nil || task.date?.repeat != nil
        containerStack.setCustomSpacing(spacingAfterTaskDescription ? 30 : 0, after: taskDescription)
        let spacingAfterSubtasksTable = task.date?.date != nil || task.date?.reminder != nil || task.date?.repeat != nil
        containerStack.setCustomSpacing(spacingAfterSubtasksTable ? 30 : 0, after: subtasksTable)
    }
    
    private func setupNavigationBar() {
        applySharedNavigationBarAppearance()
        navigationItem.rightBarButtonItem = actionsButton
    }
    
    var popMenuVc: PopMenuViewController?
    // MARK: - POPUP
    @objc private func actionsButtonClicked() {
        var actions: [PopuptodoAction] = []
        if viewModel.subtasksModels[0].items.isEmpty {
            actions.append(PopuptodoAction(title: "Add checklist", image: UIImage(named: "list-check"), didSelect: { [weak self] action in
                self?.addChecklistSelected(action: action)
            }))
        }
        if tokenField.isHidden {
            actions.append(PopuptodoAction(title: "Add Tags", image: UIImage(named: "tag"), didSelect: { [weak self] action in
                self?.addTagsSelected(action: action)
            }))
        }
        if taskDescription.isHidden {
            actions.append(PopuptodoAction(title: "Add Description", image: UIImage(named: "taskdescription"), didSelect: { [weak self] action in
                self?.addDescriptionSelected(action: action)
            }))
        }
        actions.append(contentsOf: [
            PopuptodoAction(title: "Select Priority", image: UIImage(named: "flag"), didSelect: { [weak self] action in
                self?.selectPrioritySelected(action: action)
            }),
            PopuptodoAction(title: "Add Calendar", image: UIImage(named: "calendar-plus"), didSelect: { [weak self] action in
                self?.addCalendarSelected(action: action)
            }),
            PopuptodoAction(title: "Delete To-Do", image: UIImage(named: "trash"), didSelect: { [weak self] action in
                self?.deleteTodoSelected(action: action)
            }),
        ])
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.shouldDismissOnSelection = false
        popMenu.appearance = .appAppearance
        popMenuVc = popMenu
        present(popMenu, animated: true)
    }
    func addDescriptionSelected(action: PopMenuAction) {
        dismiss(animated: true, completion: nil)
        viewModel.addEmptyDescription()
    }
    
    func addChecklistSelected(action: PopMenuAction) {
        dismiss(animated: true, completion: nil)
        viewModel.explicitlyEnableTableView()
    }
    func addTagsSelected(action: PopMenuAction) {
        dismiss(animated: true, completion: nil)
        router.openAllTags(mode: .selection(selected: Array(viewModel.task.tags), { [weak self] tags in
            self?.viewModel.addTags(tags)
        }))
    }

    func selectPrioritySelected(action: PopMenuAction) {
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectHighPriority() }),
            PopuptodoAction(title: "Medium Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectMediumPriority() }),
            PopuptodoAction(title: "Low Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectLowPriority() }),
            PopuptodoAction(title: "No Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectNonePriority() })
        ]
        actions[0].imageTintColor = .hex("#EF4439")
        actions[1].imageTintColor = .hex("#FF9900")
        actions[2].imageTintColor = .hex("#447BFE")
        actions[3].imageTintColor = UIColor(named: "TASubElement")!
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: action.view, actions: actions)
        popMenu.appearance = .appAppearance
        
        popMenuVc?.present(popMenu, animated: true)
    }
    func addCalendarSelected(action: PopMenuAction) {
        let task = viewModel.task
        dismiss(animated: true, completion: nil)
        router.openDateVc(reminder: task.date?.reminder, repeat: task.date?.repeat, date: task.date?.date) { [weak self] (newDate, newReminder, newRepeat) in
            self?.viewModel.newDate(date: newDate, reminder: newReminder, repeatt: newRepeat)
        }
    }
    func deleteTodoSelected(action: PopMenuAction) {
        dismiss(animated: true, completion: nil)
        router.navigationController.popViewController(animated: true)
        viewModel.deleteItselfInRealm()
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, indexPath: IndexPath) {
        let subtaskmodel = viewModel.subtasksModels[0].items[indexPath.row]
        switch subtaskmodel {
        case let .subtask(subtask):
            viewModel.deleteSubtask(subtask: subtask)
        default: return
        }
    }

    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
        print("didDisappear")
    }
}

extension TaskDetailsVc: AppNavigationRouterDelegate { }

extension TaskDetailsVc: ResizingTokenFieldDelegate {
    func resizingTokenField(_ tokenField: ResizingTokenField, shouldRemoveToken token: ResizingTokenFieldToken) -> Bool {
        viewModel.deleteTag(with: token.title)
        return false
    }
    func resizingTokenField(_ tokenField: ResizingTokenField, didChangeHeight newHeight: CGFloat) {
        let extraSpace: CGFloat = 30
        tokenField.snp.remakeConstraints { make in
            make.height.equalTo(newHeight + extraSpace)
        }
    }
    func resizingTokenFieldShouldCollapseTokens(_ tokenField: ResizingTokenField) -> Bool {
        false
    }
    
    func resizingTokenFieldCollapsedTokensText(_ tokenField: ResizingTokenField) -> String? {
        nil
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, configurationForDefaultCellRepresenting token: ResizingTokenFieldToken) -> DefaultTokenCellConfiguration? {
        ResizingTokenConfiguration()
    }
}

extension TaskDetailsVc: UITableViewDelegate {
    
}

extension TaskDetailsVc: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let model = viewModel.subtasksModels[0].items[indexPath.row]
        guard case .subtask = model else { return [] }
        let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionDeletion)
        deleteAction.backgroundColor = .hex("#EF4439")
        deleteAction.image = UIImage(named: "trash")?.withTintColor(UIColor(named: "TAAltBackground")!, renderingMode: .alwaysTemplate)
        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        options.minimumButtonWidth = 87
        options.maximumButtonWidth = 200
        options.expansionStyle = .selection
        return options
    }
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }

        return image.withRenderingMode(self.renderingMode)
    }
}

extension TaskDetailsVc: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newSpace = text.contains { $0.isNewline }
        switch textView {
        case taskDescription.textField:
            if newSpace { textView.resignFirstResponder() }
            break
        case taskNameh1.textField:
            guard newSpace else { break }
            if self.taskDescription.isHidden {
                self.taskNameh1.textField.resignFirstResponder()
            } else {
                _ = self.taskDescription.becomeFirstResponder()
            }
        default:
            break
        }
        return !newSpace
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case taskNameh1.textField:
            let newName = taskNameh1.text
            if !newName.isEmpty {
                viewModel.changeName(textView.text)
            }
        case taskDescription.textField:
            viewModel.changeDescription(textView.text)
            break
        default:
            break
        }
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

}
