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

final class TaskDetailsVc: UIViewController {
    private let viewModel: TaskDetailsVcVm
    private let bag = DisposeBag()
    private let layout: UICollectionViewLayout = {
        return UICollectionViewCompositionalLayout {  section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }()
    private lazy var subtasksTable = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let actionsButton = IconButton(image: UIImage(named: "dots")?.withTintColor(.black, renderingMode: .alwaysTemplate))
    private let keyboard = Typist()

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
                
                let height = options.endFrame.intersection(subtasksTable.convert(subtasksTable.bounds, to: nil)).height
                testx = options.endFrame
                if previousHeight == height { return }
                previousHeight = height
                UIView.animate(withDuration: 0.5) {
                    self.subtasksTable.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
                    view.layoutSubviews()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(subtasksTable.convert(subtasksTable.bounds, to: nil)).height
                testx = options.endFrame
                if previousHeight == height { return }
                previousHeight = height
                UIView.animate(withDuration: 0.5) {
                    self.subtasksTable.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
                    view.layoutSubviews()
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
        subtasksTable.register(SubtaskCell.self, forCellWithReuseIdentifier: SubtaskCell.reuseIdentifier)
        subtasksTable.register(SubtaskAddCell.self, forCellWithReuseIdentifier: SubtaskAddCell.reuseIdentifier)
        subtasksTable.delegate = self
        subtasksTable.backgroundColor = .clear
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<TaskDetailsVcVm.Model>> { [unowned self] (data, tableView, indexPath, model) -> UICollectionViewCell in
            switch model {
            case .addSubtask:
                let cell = tableView.dequeueReusableCell(withReuseIdentifier: SubtaskAddCell.reuseIdentifier, for: indexPath) as! SubtaskAddCell
                cell.subtaskCreated = self.viewModel.createSubtask
                return cell
            case let .subtask(subtask):
                let cell = tableView.dequeueReusableCell(withReuseIdentifier: SubtaskCell.reuseIdentifier, for: indexPath) as! SubtaskCell
                cell.configure(name: subtask.name, isDone: subtask.isDone)
                cell.delegate = self
                cell.onSelected = { self.viewModel.toggleDoneSubtask(subtask: subtask, isDone: $0) }
                return cell
            }
        }
        viewModel.reloadSubtaskCells = { [weak self] mods in
            self?.subtasksTable.reloadItems(at: mods.map { IndexPath(row: $0, section: 0) })
        }
        var wasAlreadyLoaded = false
        viewModel.subtasksUpdate
            .do(onNext: { [unowned self] _ in
                let height = CGFloat(self.viewModel.subtasksModels[0].items.count * SubtaskCell.height + 44)
                self.subtasksTableContainer.layout(self.subtasksTable).height(height).priority(.defaultLow)
                if wasAlreadyLoaded {
                UIView.animate(withDuration: 0.3) {
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
        viewModel.taskObservable
            .subscribe(onNext: { [weak self] task in
                guard let self = self else { return }
                self.checkboxh1.configure(isChecked: task.isDone)
                self.checkboxh1.configure(priority: task.priority)
                self.taskNameh1.text = task.name
                self.setTaskDescription(task.taskDescription)
                self.updateLabels(taskDate: task.date)
            })
            .disposed(by: bag)
        viewModel.tagsObservable
            .subscribe(onNext: { [weak self] tags in
                self?.updateTags()
            })
            .disposed(by: bag)
    }
    
    func setTaskDescription(_ taskDescription: String) {
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
        if taskDescription == "Emptyxpk" {
            self.taskDescription.text = ""
        } else {
            self.taskDescription.text = taskDescription
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
            self.containerStack.layoutSubviews()
        }
    }
    
    func updateTags() {
        guard !(viewModel.task?.tags.isEmpty ?? true) else {
            self.tokenField.isHidden = true
            self.spacerBeforeTokenField.isHidden = true
            return
        }
        self.tokenField.isHidden = false
        self.spacerBeforeTokenField.isHidden = false
        tokenField.removeAll()
        tokenField.append(tokens: viewModel.task?.tags.map { ResizingToken(title: $0.name) } ?? [])
    }
    
    func updateLabels(taskDate: RlmTaskDate?) {
        if taskDate?.date != nil || taskDate?.reminder != nil || taskDate?.repeat != nil {
            spacerBeforeLabels.isHidden = false
        } else {
            spacerBeforeLabels.isHidden = true
        }
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
    }
        
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    let containerStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        return stack
    }()
    
    let horizontal1: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 13
        stack.alignment = .center
        return stack
    }()
    let checkboxh1: CheckboxView = {
        let view = CheckboxView()
        view.tint = .hex("#00CE15")
        return view
    }()
    let taskNameh1: UILabel = {
        let taskLabel = UILabel()
        taskLabel.font = .systemFont(ofSize: 20, weight: .medium)
        return taskLabel
    }()
    
    let spacerBeforeTaskDescription: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return view
    }()
    
    lazy var taskDescription: MyGrowingTextView = {
        let description = MyGrowingTextView(placeholderText: "Enter description")
        let attributes: Attributes = Attributes().lineSpacing(5).foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 16, weight: .regular))
        description.placeholderAttrs = attributes
        description.textFieldAttrs = attributes
        return description
    }()
        
    let subtasksTableContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    let spacerBeforeTokenField: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 26).isActive = true
        view.isHidden = true
        return view
    }()
    
    let tokenField: ResizingTokenField = ResizingTokenField()
    
    let spacerBeforeLabels: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.isHidden = true
        return view
    }()
    
    let stackDateDetail: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        return stack
    }()
    
    let dateDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "alarm"))
        view.isHidden = true
        return view
    }()
    
    private let datesStackSeparator: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return view
    }()
    
    let stackReminderRepeat: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.spacing = 6
        stack.layoutMargins = .init(top: 6, left: 0, bottom: 0, right: 0)
        //stack.distribution = .fill
        return stack
    }()
        
    let reminderDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "bell"))
        view.isHidden = true
        return view
    }()
    
    let repeatDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "repeat"))
        view.isHidden = true
        return view
    }()
    
    func setupTokenField() {
        tokenField.delegate = self
        tokenField.itemSpacing = 4
        tokenField.allowDeletionTags = true
        tokenField.hideLabel(animated: false)
        tokenField.font = .systemFont(ofSize: 15, weight: .semibold)
        tokenField.preferredTextFieldReturnKeyType = .done
        tokenField.contentInsets = .zero
        tokenField.allowDeletionTags = false
        tokenField.heightAnchor.constraint(lessThanOrEqualToConstant: 135).isActive = true
        tokenField.isHidden = true
    }
    
    private func setupContainerView() {
        view.layout(containerView).leading(13).trailing(13).topSafe(30).bottomSafe(30) { _, _ in .lessThanOrEqual }
        containerView.layout(containerStack).leading(26).trailing(26).top(23).bottom(23)
        containerStack.isUserInteractionEnabled = true
        horizontal1.isUserInteractionEnabled = true
        horizontal1.addArrangedSubview(checkboxh1)
        horizontal1.addArrangedSubview(taskNameh1)
        horizontal1.addArrangedSubview(UIView())
        containerStack.addArrangedSubview(horizontal1)
        containerStack.addArrangedSubview(spacerBeforeTaskDescription)
        let heightConstraint = self.taskDescription.heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.isActive = true
        taskDescription.shouldSetHeight = { [weak self] in
            heightConstraint.constant = $0
            UIView.animate(withDuration: 0.5) {
                self?.containerStack.layoutSubviews()
                self?.view.layoutSubviews()
            }
        }
        containerStack.addArrangedSubview(taskDescription)
        containerStack.addArrangedSubview(spacerBeforeTokenField)
        containerStack.addArrangedSubview(tokenField)
        subtasksTableContainer.layout(subtasksTable).leading().trailing().bottom().top(26)
        containerStack.addArrangedSubview(subtasksTableContainer)
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
        navigationItem.titleLabel.text = "Task info"

        [actionsButton].forEach { $0.tintColor = .black }
        actionsButton.addTarget(self, action: #selector(actionsButtonClicked), for: .touchUpInside)
        
        navigationItem.rightViews = [actionsButton]
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
        if spacerBeforeLabels.isHidden {
            actions.append(PopuptodoAction(title: "Add Calendar", image: UIImage(named: "calendar-plus"), didSelect: addCalendarSelected))
        }
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
        view.endEditing(true)
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
        dismiss(animated: true, completion: nil)
    }
    func deleteTodoSelected(action: PopMenuAction) {
        dismiss(animated: true, completion: nil)
        viewModel.deleteItselfInRealm()
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, indexPath: IndexPath) {
        let subtaskmodel = viewModel.subtasksModels[0].items[indexPath.row]
        switch subtaskmodel {
        case let .subtask(subtask):
            let alertVc = UIAlertController(title: "Are you sure?", message: "you really wanna delete this \(subtask.name)??", preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "Hmm, not sure", style: .default))
            alertVc.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.viewModel.deleteSubtask(subtask: subtask)
            }))
            present(alertVc, animated: true, completion: nil)
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
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
            self.containerStack.layoutSubviews()
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

extension TaskDetailsVc: UICollectionViewDelegate {
    
}

extension TaskDetailsVc: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let model = viewModel.subtasksModels[0].items[indexPath.row]
        guard case .subtask = model else { return [] }
        let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionDeletion)
        deleteAction.backgroundColor = .hex("#EF4439")
        deleteAction.image = UIImage(named: "trash")?.withTintColor(.white, renderingMode: .alwaysTemplate)
        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
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
        if newSpace { textView.resignFirstResponder() }
        return !newSpace
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

}
