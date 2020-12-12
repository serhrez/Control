//
//  CreateProjectVc.swift
//  TodoApp
//
//  Created by sergey on 29.11.2020.
//

import Foundation
import UIKit
import Material
import RxSwift
import AttributedLib
import GrowingTextView
import Typist
import RxDataSources
import SwiftDate
import PopMenu

class CreateProjectVc: UIViewController {
    private let viewModel: CreateProjectVcVm
    private lazy var collectionView = UITableView()
    private let bag = DisposeBag()
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    private lazy var closeButton = CloseButton(onClicked: closeClicked)
    private lazy var clickableIcon: ClickableIconView = {
        let iconView = ClickableIconView(onClick: iconSelected)
        iconView.iconView.iconFontSize = 48
        iconView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return iconView
    }()
    private lazy var colorCircle: GappedCircle = {
        let circle = GappedCircle(circleColor: .orange, widthHeight: 22)
        circle.onClick = self.colorSelection
        circle.configure(isSelected: false, animated: false)
        return circle
    }()
    private lazy var projectNameField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 28, weight: .bold)
        textField.textColor = .hex("#242424")
        textField.delegate = self
        textField.attributedPlaceholder = "New Project".at.attributed { attr in
            attr.foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 28, weight: .bold))
        }
        return textField
    }()
    private lazy var growingTextView: GrowingTextView = {
        func attrs(_ attr: Attributes) -> Attributes {
            attr.lineSpacing(5).foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 20, weight: .regular)).firstLineHeadIndent(0).headIndent(0)
        }
        let description = GrowingTextView()
        description.attributedPlaceholder = "Notes".at.attributed(attrs)
        description.delegate = self
        description.maxLength = 70
        description.attributedText = " ".at.attributed(attrs)
        description.text = ""
        description.isScrollEnabled = true
        description.maxHeight = 120
        description.textContainerInset = .zero
        description.contentInset = .zero
        description.textContainer.lineFragmentPadding = 0
        return description
    }()
    private lazy var plusButton: CustomButton = {
        let button = CustomButton()
        button.onClick = plusClicked
        let plus = UIView()
        plus.widthAnchor.constraint(equalToConstant: 50).isActive = true
        plus.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        plus.backgroundColor = .hex("#447BFE")
        let imageView = UIImageView(image: UIImage(named: "plus"))
        plus.layout(imageView).width(18).height(18).center()
        button.layout(plus).edges()
        return button
    }()
    private let toolbarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private lazy var toolbar = Toolbar(
        onDateClicked: onDateOpenClicked,
        onTagClicked: onTagOpenClicked,
        onPriorityClicked: onPriorityOpenClicked)
    private let keyboard = Typist()

    init(viewModel: CreateProjectVcVm) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboard()
    }
    
    func setupViews() {
        view.backgroundColor = .hex("#F6F6F3")
        navigationItem.backButton.isHidden = true
        view.layout(container).top(119).bottomSafe(30).leading().trailing()
        container.layout(closeButton).top(12).trailing(12)
        clickableIcon.iconView.configure(.text("🚒"))
        view.layout(clickableIcon).top(container.anchor.top, -24).leading(26)
        container.layout(colorCircle).top(42).leading(26)
        container.layout(projectNameField).leading(61).top(37).trailing(12 + 24)
        container.layout(growingTextView).leading(61).top(projectNameField.anchor.bottom, 5).trailing(12 + 24)
        
        container.layout(collectionView).top(growingTextView.anchor.bottom, 25).leading(colorCircle.anchor.leading).trailing(closeButton.anchor.leading).bottom(Toolbar.height)
        container.layout(toolbarContainer).trailing().leading().bottom()
        toolbarContainer.snp.makeConstraints { make in
            make.height.equalTo(Toolbar.height)
        }
        toolbarContainer.layout(toolbar).trailing().leading().top()
        container.layout(plusButton).trailing(20)
        plusButton.snp.makeConstraints { make in
            make.bottom.equalTo(-70)
        }
        setupTableView()
    }
    
    private func setupTableView() {
        collectionView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.contentOffset = .zero
        collectionView.contentInset = .zero
        collectionView.rowHeight = UITableView.automaticDimension
        collectionView.separatorStyle = .none
        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimSection<CreateProjectVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UITableViewCell in
            if model.isEmptySpace {
                let cell = UITableViewCell()
                cell.heightAnchor.constraint(equalToConstant: 10).isActive = true
                return cell
            }
            print("cell for row at \(indexPath)")
            let cell = collectionView.dequeueReusableCell(withIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
            let task = model.task
            switch model.mode {
            case .addTask:
                cell.configureAsNew(tagAllowed: model.isTagsAllowed)
                cell.onCreatedTask = { viewModel.taskCreated(task) }
                cell.onTaskNameChanged = { self.viewModel.taskNameChanged(task: task, name: $0) }
                cell.onSelected = { self.viewModel.changeIsDone(task: task, isDone: $0) }
            case .task:
                cell.configure(text: task.name, date: task.date?.date, priority: task.priority, isSelected: task.isDone, tags: Array(task.tags), tagAllowed: model.isTagsAllowed)
                cell.onDeleteTag = { self.viewModel.tagDeleted(with: $0, from: task) }
                cell.addToken = { self.viewModel.tagAdded(with: $0, to: task) }
                cell.onTaskNameChanged = { self.viewModel.taskNameChanged(task: task, name: $0) }
                cell.onSelected = { self.viewModel.changeIsDone(task: task, isDone: $0) }
                cell.onDeleteTask = { self.viewModel.shouldDelete(task) }
            }
            cell.onFocused = { viewModel.onFocusChanged(to: $0 ? task : nil)  }
            return cell
        }
        dataSource.animationConfiguration = .init(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .none)

        viewModel.reloadTasksCells = { [weak self] mods in
            print("viewModel.reloadTasksCells \(mods)")
            self?.collectionView.reloadRows(at: mods.map { IndexPath(row: $0, section: 0) }, with: .none)
//            self?.collectionView.layer.removeAllAnimations()
        }
        viewModel.bringFocusToTagsAtIndex = { [unowned self] rowIndex in
            print("viewModel.bringFocusToTagsAtIndex \(rowIndex)")
            let cell = collectionView.cellForRow(at: IndexPath(row: rowIndex, section: 0)) as! TaskCell
            UIView.performWithoutAnimation {
                cell.bringFocusToTokenField()
            }
        }
        viewModel.bringFocusToTextField = { [unowned self] rowIndex in
            print("viewModel.bringFocusToTextField \(rowIndex)")
            if rowIndex == collectionView.numberOfRows(inSection: 0) - 1 {
                collectionView.scrollToRow(at: IndexPath(row: rowIndex, section: 0), at: .bottom, animated: false)
            }
            guard let cell = collectionView.cellForRow(at: IndexPath(row: rowIndex, section: 0)) as? TaskCell else { print("BRING FOCUS HERE ALERT viewModel.bringFocusToTextField"); return }
            cell.bringFocusToTextField()
        }
        viewModel.tasksUpdate
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    private func setupKeyboard() {
        let heightChangeSubject = PublishSubject<CGFloat>()
        keyboard
            //.toolbar(scrollView: collectionView)
            .on(event: .willChangeFrame) { [unowned self] options in
                print("height changed to: \(options.endFrame.intersection(container.frame).height)")
                heightChangeSubject.on(.next((options.endFrame.intersection(container.frame).height)))
            }
            .on(event: .willHide) { [unowned self] options in
                heightChangeSubject.on(.next(options.endFrame.intersection(container.frame).height))
            }
            .start()
        
        Observable.merge(heightChangeSubject
                            .debounce(.milliseconds(50), scheduler: MainScheduler.instance),
                         heightChangeSubject
                             .filter { $0 != 0 })
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] height in
                print("height changed to2 \(height)")
                toolbarContainer.snp.remakeConstraints { make in
                    make.height.equalTo(Toolbar.height + height)
                }
                plusButton.snp.remakeConstraints { make in
                    make.bottom.equalTo(-(70 + height))
                }
                UIView.animate(withDuration: 0.5) {
                    self.collectionView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
                    view.layoutSubviews()
                }
            })
            .disposed(by: bag)
    }
    
    private func plusClicked() {
        print("plus clicked")
    }
    
    private func closeClicked() {
        print("close clicked")
    }
    private func iconSelected() {
        print("iconSelected")
        clickableIcon.motionIdentifier = "wq"
    }
    
    private func colorSelection() {
        let colorPicker = ColorPicker(viewSource: colorCircle)
        present(colorPicker, animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func onDateOpenClicked() {
        let task = viewModel.taskToAddComponents
        view.endEditing(true)
        router.openDateVc(reminder: task.date?.reminder, repeat: task.date?.repeat, date: task.date?.date) { [weak self] (date, reminder, repeat) in
            self?.viewModel.setDate(to: task, date: (date, reminder, `repeat`))
        }
    }
    private func onTagOpenClicked() {
        viewModel.setTagAllowed(to: viewModel.taskToAddComponents)
    }
    private func onPriorityOpenClicked() {
        let task = viewModel.taskToAddComponents
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectPriority(to: task, priority: .high) }),
            PopuptodoAction(title: "Medium Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectPriority(to: task, priority: .medium) }),
            PopuptodoAction(title: "Low Priority", image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), didSelect: { [weak self] _ in self?.viewModel.selectPriority(to: task, priority: .low) })
        ]
        actions[0].imageTintColor = .hex("#EF4439")
        actions[1].imageTintColor = .hex("#FF9900")
        actions[2].imageTintColor = .hex("#447BFE")
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: toolbar.tagView, actions: actions)
        popMenu.appearance = .appAppearance
        popMenu.isCrutchySolution1 = true
        addChild(popMenu)
        popMenu.view.layer.opacity = 0
        view.layout(popMenu.view).top().left().right().bottom()
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
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
    var estimatedHeights: [IndexPath: CGFloat] = [:]
}
extension CreateProjectVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        estimatedHeights[indexPath] = cell.frame.height
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedHeights[indexPath] ?? .zero
    }
}

extension CreateProjectVc: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case projectNameField:
            projectNameField.resignFirstResponder()
            if growingTextView.text.isEmpty { growingTextView.becomeFirstResponder() }
            return true
        default:
            return true
        }
    }
}

extension CreateProjectVc: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newSpace = text.contains { $0.isNewline }
        if newSpace { textView.resignFirstResponder() }
        return !newSpace
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        switch textView {
        case growingTextView:
            growingTextView.resignFirstResponder()
            return true
        default:
            return true
        }
    }
}

extension CreateProjectVc: AppNavigationRouterDelegate { }
