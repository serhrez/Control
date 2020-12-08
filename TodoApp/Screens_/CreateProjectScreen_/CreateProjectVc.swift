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

class CreateProjectVc: UIViewController {
    private let viewModel: CreateProjectVcVm
    private let flowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
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
        container.layout(plusButton).trailing(20).bottom(70)
        
        container.layout(toolbar).trailing().leading().bottom()
        container.layout(collectionView).top(growingTextView.anchor.bottom, 25).leading(colorCircle.anchor.leading).trailing(closeButton.anchor.leading).bottom(toolbar.anchor.top)
        setupTableView()
    }
    
    private func setupTableView() {
        collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .green
        collectionView.clipsToBounds = true
        collectionView.contentOffset = .zero
        collectionView.contentInset = .zero
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<CreateProjectVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            let task: RlmTask
            let isAddTask: Bool
            let isTagAllowed: Bool
            switch model {
            case let .addTask(xtask, xisTagAllowed):
                task = xtask
                isAddTask = true
                isTagAllowed = xisTagAllowed
            case let .task(xtask, xisTagAllowed):
                task = xtask
                isAddTask = false
                isTagAllowed = xisTagAllowed
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
            if isAddTask {
                cell.configureAsNew(tagAllowed: isTagAllowed)
                cell.onCreatedTask = { viewModel.taskCreated(task) }
//                cell.onSelected = { task.isDone = $0 }
//                cell.onTaskNameChanged = { task.name = $0 }
                cell.onTaskNameChanged = { self.viewModel.taskNameChanged(task: task, name: $0) }
                cell.onSelected = { self.viewModel.changeIsDone(task: task, isDone: $0) }
            } else {
                cell.configure(text: task.name, date: task.date?.date, priority: task.priority, isSelected: task.isDone, tags: Array(task.tags), tagAllowed: isTagAllowed)
                cell.onDeleteTag = { self.viewModel.tagDeleted(with: $0, from: task) }
                cell.addToken = { self.viewModel.tagAdded(with: $0, to: task) }
                cell.onTaskNameChanged = { self.viewModel.taskNameChanged(task: task, name: $0) }
                cell.onSelected = { self.viewModel.changeIsDone(task: task, isDone: $0) }
                cell.onDeleteTask = { self.viewModel.shouldDelete(task) }
            }
            cell.onFocused = { viewModel.onFocusChanged(to: $0 ? task : nil)  }
            return cell
        }

        viewModel.reloadTasksCells = { [weak self] mods in
            print("viewModel.reloadTasksCells \(mods)")
            self?.collectionView.reloadItems(at: mods.map { IndexPath(row: $0, section: 0) })
            self?.collectionView.layer.removeAllAnimations()
        }
        viewModel.tasksUpdate
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.backgroundColor = .clear
    }

    private func sss() {
        
    }
    
    private func setupKeyboard() {
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.height
                UIView.animate(withDuration: 0) {
                    self.view.layout(self.container).bottomSafe(height - self.view.safeAreaInsets.bottom)
                    self.view.layoutIfNeeded()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                view.layout(self.container).bottomSafe()
            }
            .start()
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
        router.openDateVc(reminder: task.date?.reminder, repeat: task.date?.repeat, date: task.date?.date) { [weak self] (date, reminder, repeat) in
            self?.viewModel.setDate(to: task, date: (date, reminder, `repeat`))
        }
    }
    private func onTagOpenClicked() {
        viewModel.setTagAllowed(to: viewModel.taskToAddComponents)
    }
    private func onPriorityOpenClicked() {
        
    }
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension CreateProjectVc: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == projectNameField {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension CreateProjectVc: UITextViewDelegate {
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

extension CreateProjectVc: AppNavigationRouterDelegate { }

extension CreateProjectVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, height: 1)
    }
}
extension CreateProjectVc: UICollectionViewDelegate {
}
