//
//  InboxTasksVc.swift
//  TodoApp
//
//  Created by sergey on 16.11.2020.
//

import Foundation
import UIKit
import Material
import PopMenu
import RxDataSources
import RxSwift

final class InboxTasksVc: UIViewController {
    private let tasksToolbar = AllTasksToolbar(frame: .zero)
    private let actionsButton = IconButton(image: UIImage(named: "dots")?.withTintColor(.black, renderingMode: .alwaysTemplate))
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let viewModel: InboxTasksVcVm = .init()
    private let bag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        setupCollectionView()
        setupNavigationBar()
        view.backgroundColor = .hex("#F6F6F3")
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(30)
    }
    
    func setupCollectionView() {
        view.layout(collectionView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(TaskCellx1.self, forCellWithReuseIdentifier: TaskCellx1.reuseIdentifier)
        collectionView.register(InboxDoneTaskCell.self, forCellWithReuseIdentifier: InboxDoneTaskCell.reuseIdentifier)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<InboxTasksVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            switch model {
            case let .task(task):
                let taskCell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCellx1.reuseIdentifier, for: indexPath) as! TaskCellx1
                taskCell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasChecklist: !task.subtask.isEmpty) {
                    _ = try! RealmProvider.inMemory.realm.write {
                        task.isDone.toggle()
                    }
                }
                return taskCell
            case let .doneTask(task):
                let doneCell = collectionView.dequeueReusableCell(withReuseIdentifier: InboxDoneTaskCell.reuseIdentifier, for: indexPath) as! InboxDoneTaskCell
                doneCell.configure(text: task.name) {
                    _ = try! RealmProvider.inMemory.realm.write {
                        task.isDone.toggle()
                    }
                }
                return doneCell
            }
        }
        viewModel.modelsUpdate
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.delegate = self

    }
    
    func setupNavigationBar() {
        navigationItem.titleLabel.text = "Inbox"
        
        actionsButton.addTarget(self, action: #selector(actionsButtonClicked), for: .touchUpInside)
        
        actionsButton.tintColor = .black
        navigationItem.rightViews = [actionsButton]
    }
    
    // MARK: - POPUP
    @objc private func actionsButtonClicked() {
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "Complete All", image: UIImage(named: "circle-check"), didSelect: completeAll),
            PopuptodoAction(title: "Duplicate Project", image: UIImage(named: "layers-subtract"), didSelect: duplicateProject),
            PopuptodoAction(title: "Project History", image: UIImage(named: "archive"), didSelect: projectHistory),
            PopuptodoAction(title: "Share Project", image: UIImage(named: "share"), didSelect: shareProject),
        ]
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.appearance = .appAppearance
        
        present(popMenu, animated: true)
    }
    
    func completeAll(action: PopMenuAction) {
        
    }
    
    func duplicateProject(action: PopMenuAction) {
        
    }
    
    func projectHistory(action: PopMenuAction) {
        
    }
    
    func shareProject(action: PopMenuAction) {
        
    }
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension InboxTasksVc: AppNavigationRouterDelegate { }

extension InboxTasksVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: indexPath.section == 0 ? 62 : 27)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 || viewModel.models[0].items.isEmpty {
            return .zero
        } else {
            return .init(top: 45, left: 0, bottom: 0, right: 0)
        }
    }
}

extension InboxTasksVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = viewModel.models[indexPath.section].items[indexPath.row]
//        switch model {
//        case .addTag:
//            viewModel.allowAdding()
//        case .addTagEnterName: break
//        case let .tag(tag):
//            print("tag selected: \(tag)")
//            break
//        }
    }
}
