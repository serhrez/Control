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
import RealmSwift
import RxDataSources
import SwipeCellKit
import Typist
import SnapKit

final class TaskDetailsVc: UIViewController {
    private let viewModel: TaskDetailsVcVm
    private let bag = DisposeBag()
    private let spacerBeforeSubtasksTable: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "spacerBeforeSubtasksTable"
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.isHidden = true
        return view
    }()
    private lazy var subtasksTable: UITableView = {
        let collectionView = UITableView(frame: .zero)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    private lazy var actionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dots"), style: .done, target: self, action: #selector(actionsButtonClicked))
        button.tintColor = .hex("#242424")
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
        view.backgroundColor = .hex("#F6F6F3")
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
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.intersection(scrollView.convert(scrollView.bounds, to: nil)).height
                testx = options.endFrame
                if previousHeight == height { return }
                previousHeight = height
                UIView.animate(withDuration: 0.5) {
                    self.scrollView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(scrollView.convert(scrollView.bounds, to: nil)).height
                testx = options.endFrame
                if previousHeight == height { return }
                previousHeight = height
                UIView.animate(withDuration: 0.5) {
                    self.scrollView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
                }
            }
            .start()
    }
    
    private func setupBindings() {
        checkboxh1.onSelected = viewModel.toggleDone
        tokenField.onPlusButtonClicked = { [unowned self] in
            self.addTagsSelected(action: PopuptodoAction())
        }
    }
    
    private func setupTableView() {
        subtasksTable.register(SubtaskCell.self, forCellReuseIdentifier: SubtaskCell.reuseIdentifier)
        subtasksTable.register(SubtaskAddCell.self, forCellReuseIdentifier: SubtaskAddCell.reuseIdentifier)
        subtasksTable.delegate = self
        subtasksTable.backgroundColor = .clear
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimSection<TaskDetailsVcVm.Model>> { [unowned self] (data, tableView, indexPath, model) -> UITableViewCell in
            switch model {
            case .addSubtask:
                let cell = tableView.dequeueReusableCell(withIdentifier: SubtaskAddCell.reuseIdentifier, for: indexPath) as! SubtaskAddCell
                cell.subtaskCreated = self.viewModel.createSubtask
                return cell
            case let .subtask(subtask):
                let cell = tableView.dequeueReusableCell(withIdentifier: SubtaskCell.reuseIdentifier, for: indexPath) as! SubtaskCell
                cell.configure(name: subtask.name, isDone: subtask.isDone)
                cell.delegate = self
                cell.onSelected = { self.viewModel.toggleDoneSubtask(subtask: subtask, isDone: $0) }
                return cell
            }
        }
        viewModel.reloadSubtaskCells = { [weak self] mods in
            self?.subtasksTable.reloadRows(at: mods.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        var wasAlreadyLoaded = false
        viewModel.subtasksUpdate
            .do(onNext: { [unowned self] _ in
                let itemsCount = self.viewModel.subtasksModels[0].items.count
                let height = CGFloat(itemsCount * SubtaskCell.height)// + (itemsCount > 0 ? 44 : 0))
                self.subtasksTable.snp.remakeConstraints { make in
                    make.height.equalTo(height)
                }
                self.spacerBeforeSubtasksTable.isHidden = height < 5
                self.updateTagsSpacer()
                if wasAlreadyLoaded {
                    UIView.animate(withDuration: 0.5) {
                        self.view.layoutIfNeeded()
                    }
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
        self.taskNameh1.text = viewModel.task?.name
        self.setTaskDescription(viewModel.task?.taskDescription ?? "")
        viewModel.shouldEnableTaskDescription = explicitlyEnableTaskDescription
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
            self.spacerBeforeTaskDescription.isHidden = true
            return
        }
        self.taskDescription.isHidden = false
        spacerBeforeTaskDescription.isHidden = false
        self.taskDescription.text = taskDescription
    }
    
    func explicitlyEnableTaskDescription() {
        self.taskDescription.isHidden = false
        spacerBeforeTaskDescription.isHidden = false
        layoutAnimate()
    }
    
    func updateTags() {
        defer {
            layoutAnimate()
        }
        guard !(viewModel.task?.tags.isEmpty ?? true) else {
            self.tokenField.isHidden = true
            self.tokenField.removeAllTokens()
            self.spacerBeforeTokenField.isHidden = true
            self.spacerAfterTokenField.isHidden = true
            return
        }
        self.tokenField.isHidden = false
        self.spacerBeforeTokenField.isHidden = false
        self.spacerAfterTokenField.isHidden = false
        updateTagsSpacer()
        let old = tokenField.tokens as? [ResizingToken]
        let newTags = ModelFormatt.tagsSorted(tags: viewModel.task.flatMap { Array($0.tags) } ?? []).map { ResizingToken(title: $0.name) }
        tokenField.deepdiff(old: old ?? [], new: newTags)
    }
    
    func updateTagsSpacer() {
        guard !tokenField.isHidden else { return }
        self.spacerAfterTokenField.isHidden = false
        if !self.viewModel.subtasksModels[0].items.isEmpty {
            self.spacerBeforeSubtasksTable.isHidden = true
            if !dateDetailLabel.isHidden || !reminderDetailLabel.isHidden || !repeatDetailLabel.isHidden {
                self.spacerBeforeLabels.isHidden = false
            }
            return
        }
        let date = viewModel.task?.date
        let isHid = (date?.date != nil || date?.reminder != nil || date?.repeat != nil)
        if isHid {
            self.spacerBeforeLabels.isHidden = true
            return
        }
        self.spacerAfterTokenField.isHidden = true
    }
    
    func updateLabels(taskDate: RlmTaskDate?) {
        datesStackSeparator.isHidden = !(taskDate?.date != nil && (taskDate?.reminder != nil || taskDate?.repeat != nil))
        spacerBeforeLabels.isHidden = !(taskDate?.date != nil || taskDate?.reminder != nil || taskDate?.repeat != nil)
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
        updateTagsSpacer()
        layoutAnimate()
    }
        
    let containerView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "containerView"
        view.backgroundColor = .white
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
        stack.alignment = .center
        return stack
    }()
    private let checkboxh1: CheckboxView = {
        let view = CheckboxView()
        view.tint = .hex("#00CE15")
        view.accessibilityIdentifier = "checkboxh1"
        return view
    }()
    private lazy var taskNameh1: UITextField = {
        let taskLabel = UITextField()
        taskLabel.font = .systemFont(ofSize: 20, weight: .medium)
        taskLabel.accessibilityIdentifier = "taskNameh1"
        taskLabel.attributedPlaceholder = "Call to John Wick?".at.attributed { $0.font(.systemFont(ofSize: 20, weight: .medium)).foreground(color: .hex("#A4A4A4")) }
        taskLabel.delegate = self
        return taskLabel
    }()
    
    private let spacerBeforeTaskDescription: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "spaceBeforeTaskDescription"
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return view
    }()
    
    private lazy var taskDescription: MyGrowingTextView = {
        let description = MyGrowingTextView(placeholderText: "Enter description", scrollBehavior: .noScroll)
        description.accessibilityIdentifier = "taskDescription"
        let attributes: Attributes = Attributes().lineSpacing(5).foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 16, weight: .regular))
        description.placeholderAttrs = attributes
        description.textFieldAttrs = attributes
        description.growingTextFieldDelegate = self
        return description
    }()
        
    private let spacerBeforeTokenField: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "spacerBeforeTokenField"
        view.heightAnchor.constraint(equalToConstant: 26).isActive = true
        view.isHidden = true
        return view
    }()
    private let spacerAfterTokenField: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "spacerAfterTokenField"
        view.heightAnchor.constraint(equalToConstant: 10).isActive = true
        view.isHidden = true
        return view
    }()
    
    private let tokenField: ResizingTokenField = ResizingTokenField()
    
    private let spacerBeforeLabels: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "spacerBeforeLabels"
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.isHidden = true
        return view
    }()
    
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
        //stack.distribution = .fill
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
        horizontal1.addArrangedSubview(checkboxh1)
        horizontal1.addArrangedSubview(taskNameh1)
        horizontal1.addArrangedSubview(UIView())
        containerStack.addArrangedSubview(horizontal1)
        containerStack.addArrangedSubview(spacerBeforeTaskDescription)
        let taskDescriptionHeight = self.taskDescription.heightAnchor.constraint(equalToConstant: 40)
        taskDescriptionHeight.isActive = true
        taskDescription.shouldSetHeight = { [weak self] in
            taskDescriptionHeight.constant = $0
            self?.layoutAnimate()
        }
        containerStack.addArrangedSubview(taskDescription)
        containerStack.addArrangedSubview(spacerBeforeTokenField)
        containerStack.addArrangedSubview(tokenField)
        containerStack.addArrangedSubview(spacerAfterTokenField)
        containerStack.addArrangedSubview(spacerBeforeSubtasksTable)
        containerStack.addArrangedSubview(subtasksTable)
        containerStack.addArrangedSubview(spacerBeforeLabels)
        stackDateDetail.addArrangedSubview(dateDetailLabel)
        stackDateDetail.addArrangedSubview(UIView()) // empty view
        
        containerStack.addArrangedSubview(stackDateDetail)
        stackReminderRepeat.addArrangedSubview(reminderDetailLabel)
        stackReminderRepeat.addArrangedSubview(repeatDetailLabel)
        stackReminderRepeat.addArrangedSubview(UIView()) // empty view
        containerStack.addArrangedSubview(datesStackSeparator) // empty view
        containerStack.addArrangedSubview(stackReminderRepeat)
    }
    
    private func setupNavigationBar() {
        applySharedNavigationBarAppearance()
        navigationItem.rightBarButtonItem = actionsButton
    }
    
    
    var popMenuVc: PopMenuViewController?
    // MARK: - POPUP
    @objc private func actionsButtonClicked() {
        var actions: [PopuptodoAction] = []
        if taskDescription.isHidden {
            actions.append(PopuptodoAction(title: "Add description", image: UIImage(named: "plus"), didSelect: addDescriptionSelected))
        }
        if viewModel.subtasksModels[0].items.isEmpty {
            actions.append(PopuptodoAction(title: "Add checklist", image: UIImage(named: "list-check"), didSelect: addChecklistSelected))
        }
        if tokenField.isHidden {
            actions.append(PopuptodoAction(title: "Add Tags", image: UIImage(named: "tag"), didSelect: addTagsSelected))
        }
        actions.append(PopuptodoAction(title: "Add Calendar", image: UIImage(named: "calendar-plus"), didSelect: addCalendarSelected))
        actions.append(contentsOf: [
            PopuptodoAction(title: "Select Priority", image: UIImage(named: "flag"), didSelect: selectPrioritySelected),
            PopuptodoAction(title: "Delete To-Do", image: UIImage(named: "trash"), didSelect: deleteTodoSelected),
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
        router.openAllTags(mode: .selection(selected: viewModel.task.flatMap { Array($0.tags) } ?? [], viewModel.addTags))
    }

    func selectPrioritySelected(action: PopMenuAction) {
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectHighPriority() }),
            PopuptodoAction(title: "Medium Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectMediumPriority() }),
            PopuptodoAction(title: "Low Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectLowPriority() })
        ]
        actions[0].imageTintColor = .hex("#EF4439")
        actions[1].imageTintColor = .hex("#FF9900")
        actions[2].imageTintColor = .hex("#447BFE")
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: action.view, actions: actions)
        popMenu.appearance = .appAppearance
        
        popMenuVc?.present(popMenu, animated: true)
    }
    func addCalendarSelected(action: PopMenuAction) {
        guard let task = viewModel.task else { return }
        dismiss(animated: true, completion: nil)
        router.openDateVc(reminder: task.date?.reminder, repeat: task.date?.repeat, date: task.date?.date) { (newDate, newReminder, newRepeat) in
            _ = try! RealmProvider.main.realm.write {
                if newDate == nil && newReminder == nil && newRepeat == nil {
                    task.date = nil
                } else {
                    task.date = RlmTaskDate(date: newDate, reminder: newReminder, repeat: newRepeat)
                }
            }
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
    }
}

extension TaskDetailsVc: AppNavigationRouterDelegate { }

extension TaskDetailsVc: ResizingTokenFieldDelegate {
    func resizingTokenField(_ tokenField: ResizingTokenField, shouldRemoveToken token: ResizingTokenFieldToken) -> Bool {
        viewModel.deleteTag(with: token.title)
        return false
    }
    func resizingTokenField(_ tokenField: ResizingTokenField, didChangeHeight newHeight: CGFloat) {
        let extraSpace = tokenField.itemHeight * 1.5
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
        deleteAction.image = UIImage(named: "trash")?.withTintColor(.white, renderingMode: .alwaysTemplate)
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

extension TaskDetailsVc: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case taskNameh1:
            if taskDescription.isHidden {
                taskNameh1.resignFirstResponder()
            } else {
                _ = taskDescription.becomeFirstResponder()
            }
        default: break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case taskNameh1:
            if let newName = taskNameh1.text,
               !newName.isEmpty {
                viewModel.changeName(newName)
            }
        default: break
        }
    }
}

extension TaskDetailsVc: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch textView {
        case taskDescription.textField:
            break
        default:
            break
        }
        let newSpace = text.contains { $0.isNewline }
        if newSpace { textView.resignFirstResponder() }
        return !newSpace
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
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
