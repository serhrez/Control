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
//        collectionView.estimatedRowHeight = UITableView.automaticDimension
//        collectionView.rowHeight = UITableView.automaticDimension
//        collectionView.separatorStyle = .none
        var allTags1 = Array(RealmProvider.main.realm.objects(RlmTag.self)).shuffled().dropFirst(Int.random(in: 1...3))
        var allTags2 = Array(RealmProvider.main.realm.objects(RlmTag.self)).shuffled().dropFirst(Int.random(in: 1...3))
        let date1 = ((Int.random(in: 1...2) == 1) ? DateInRegion.randomDate().date : nil)
        let date2 = ((Int.random(in: 1...2) == 1) ? DateInRegion.randomDate().date : nil)
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<CreateProjectVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
//            switch model {
//            case .addTask:
            let allTags = indexPath.row == 1 ? allTags2 : allTags1
            let date = indexPath.row == 1 ? date2 : date1

                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
//                cell.configure(text: "egww", date: Date(), priority: .medium, isSelected: true, tags: Array(RealmProvider.main.realm.objects(RlmTag.self)))
                cell.configure(text: nil, date: date, priority: [Priority.high, Priority.medium, Priority.low, Priority.none].shuffled().first!, isSelected: false, tags: Array(allTags))
            cell.onDeleteTag = {
                indexPath.row == 1 ? allTags2.removeLast() : allTags1.removeLast()
//                collectionView.reloadItemsAtIndexPaths([indexPath], animationStyle: .none)
//                UIView.performWithoutAnimation {
                                    collectionView.reloadItems(at: [indexPath])
//                }
            }
            cell.addToken = {
                indexPath.row == 1 ? allTags2.append(.init(name: $0)) : allTags1.append(.init(name: $0))
//                UIView.performWithoutAnimation {
                                    collectionView.reloadItems(at: [indexPath])
//                }
            }
//                return cell
//            case let .task(task):
//                let cell = collectionView.dequeueReusableCell(withIdentifier: TaskCell.reuseIdentifier, for: indexPath) as! TaskCell
//                cell.backgroundColor = .blue

//                cell.subtaskCreated = self.viewModel.taskCreated
                return cell
//            }
        }
//        var timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            self.collectionView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//
//        var timer2 = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            self.collectionView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
//        }
//        }

        viewModel.reloadTasksCells = { [weak self] mods in
            print("viewModel.reloadTasksCells \(mods)")
            self?.collectionView.reloadItems(at: mods.map { IndexPath(row: $0, section: 0) })
        }
        viewModel.tasksUpdate
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.backgroundColor = .clear
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
