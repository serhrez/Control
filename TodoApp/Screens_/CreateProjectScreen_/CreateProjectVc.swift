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
    private let tableView = UITableView()
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
        onDateClicked: { print("onDateClicked") },
        onTagClicked: { print("onTagCLicked") },
        onPriorityClicked: { print("onPriorityClicked") })
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
        container.layout(tableView).top(growingTextView.anchor.bottom, 25).leading(colorCircle.anchor.leading).trailing(closeButton.anchor.leading).bottom(toolbar.anchor.top)
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        let allTags1 = Array(RealmProvider.main.realm.objects(RlmTag.self)).shuffled().dropFirst(Int.random(in: 1...10))
        let allTags2 = Array(RealmProvider.main.realm.objects(RlmTag.self)).shuffled().dropFirst(Int.random(in: 1...10))

        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimSection<CreateProjectVcVm.Model>> { [unowned self] (data, tableView, indexPath, model) -> UITableViewCell in
//            switch model {
//            case .addTask:
            let allTags = indexPath.row == 1 ? allTags1 : allTags2
                
                let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
//                cell.configure(text: "egww", date: Date(), priority: .medium, isSelected: true, tags: Array(RealmProvider.main.realm.objects(RlmTag.self)))
                cell.configure(text: nil, date: ((Int.random(in: 1...2) == 1) ? DateInRegion.randomDate().date : nil), priority: [Priority.high, Priority.medium, Priority.low, Priority.none].shuffled().first!, isSelected: false, tags: Array(allTags))
//                return cell
//            case let .task(task):
//                let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
//                cell.backgroundColor = .blue

//                cell.subtaskCreated = self.viewModel.taskCreated
                return cell
//            }
        }
//        var timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//
//        var timer2 = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
//        }
//        }


        viewModel.reloadTasksCells = { [weak self] mods in
            self?.tableView.reloadRows(at: mods.map { IndexPath(row: $0, section: 0) }, with: .bottom)
        }
        viewModel.tasksUpdate
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        tableView.backgroundColor = .clear
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
    
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
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

extension CreateProjectVc: UITableViewDelegate {
}
