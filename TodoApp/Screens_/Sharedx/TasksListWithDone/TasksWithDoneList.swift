//
//  TasksWithDoneList.swift
//  TodoApp
//
//  Created by sergey on 24.12.2020.
//

import Foundation
import UIKit
import Material
import RxDataSources
import RxSwift
import SwipeCellKit

class TasksWithDoneList: UIView {
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<Model>>
    private let collectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        UICollectionViewFlowLayout()
////        let interLineSpacing: CGFloat = 7
////        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
////                                              heightDimension: .fractionalHeight(1.0))
////        let item = NSCollectionLayoutItem(layoutSize: itemSize)
////        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
////                                              heightDimension: .absolute(62 + interLineSpacing))
////        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
////        group.contentInsets = .init(top: 0, leading: 0, bottom: interLineSpacing, trailing: 0)
////        let section = NSCollectionLayoutSection(group: group)
////        return UICollectionViewCompositionalLayout(section: section)
//    }()
    private lazy var tableView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    private lazy var dataSource: DataSource = makeDataSource()
    private let bag = DisposeBag()
    private let onSelected: (RlmTask) -> Void
    private let shouldDelete: ((RlmTask) -> Void)?
    private var currentItems: [AnimSection<Model>]?
    private let itemsToDataSource = PublishSubject<[AnimSection<Model>]>()
    private var __previousSorting: ProjectSorting = .byCreatedAt
    var sorting: ProjectSorting = .byCreatedAt {
        didSet {
            if __previousSorting == sorting { return }
            __previousSorting = sorting
            if let currentItems = currentItems {
                let sorted = currentItems.map { AnimSection(identity: $0.identity, items: self.sortCurrentItems($0.items, sorting: self.sorting)) }
                self.currentItems = sorted
                itemsToDataSource.onNext(sorted)
            }
        }
    }
    let itemsInput = PublishSubject<[RlmTask]>()
    let gradientView = GradientView()
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            tableView.contentInset = contentInsets
        }
    }
    
    init(onSelected: @escaping (RlmTask) -> Void, shouldDelete: ((RlmTask) -> Void)?, isGradientHidden: Bool = false) {
        self.onSelected = onSelected
        self.shouldDelete = shouldDelete
        super.init(frame: .zero)
        gradientView.isHidden = isGradientHidden
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layout(tableView).leading().trailing().bottom().top(-7)
        layout(gradientView).bottom().leading().trailing().height(216)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        collectionLayout.minimumLineSpacing = 7
        tableView.alwaysBounceVertical = true
        tableView.register(TasksListTaskCell.self, forCellWithReuseIdentifier: TasksListTaskCell.reuseIdentifier)
        tableView.register(DoneTasksListTaskCell.self, forCellWithReuseIdentifier: DoneTasksListTaskCell.reuseIdentifier)
        tableView.delegate = self
        itemsToDataSource
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        itemsInput
            .map { tasks -> [AnimSection<Model>] in
                let section1 = tasks.filter { !$0.isDone }.map { TasksWithDoneList.Model.task($0) }
                let section2 = tasks.filter { $0.isDone }.map { TasksWithDoneList.Model.doneTask($0) }
                return [AnimSection(items: section1 + section2)]
            }
            .compactMap { [weak self] animSections in
                guard let self = self else { return nil }
                return animSections.map { AnimSection(identity: $0.identity, items: self.sortCurrentItems($0.items, sorting: self.sorting))  }
            }
            .do(onNext: { [weak self] in
                self?.currentItems = $0
            })
            .bind(to: itemsToDataSource)
            .disposed(by: bag)
    }
    
    func sortCurrentItems(_ models: [Model], sorting: ProjectSorting) -> [Model] {
        return models.sorted { model1, model2 -> Bool in
            switch (model1, model2) {
            case (.task, .doneTask): return true
            case (.doneTask, .task): return false
            default: break
            }
            switch sorting {
            case .byCreatedAt:
                return model1.task.createdAt > model2.task.createdAt
            case .byName:
                return model1.task.name != model2.task.name ?
                model1.task.name > model2.task.name :
                model1.task.createdAt > model2.task.createdAt
            case .byPriority:
                return model1.task.priority != model2.task.priority ?
                model1.task.priority > model2.task.priority :
                model1.task.createdAt > model2.task.createdAt
            }
        }
    }

    func makeDataSource() -> DataSource {
        DataSource { [weak self] (data, tableView, indexPath, model) -> UICollectionViewCell in
            switch model {
            case let .task(task):
                let taskCell = tableView.dequeueReusableCell(withReuseIdentifier: TasksListTaskCell.reuseIdentifier, for: indexPath) as! TasksListTaskCell
                taskCell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, otherTags: task.tags.count >= 2, priority: task.priority, hasChecklist: !task.subtask.isEmpty) {
                    _ = try! RealmProvider.main.realm.write {
                        task.isDone.toggle()
                    }
                }
                taskCell.delegate = self
                return taskCell
            case let .doneTask(task):
                let doneCell = tableView.dequeueReusableCell(withReuseIdentifier: DoneTasksListTaskCell.reuseIdentifier, for: indexPath) as! DoneTasksListTaskCell
                doneCell.configure(text: task.name) {
                    _ = try! RealmProvider.main.realm.write {
                        task.isDone.toggle()
                    }
                }
                doneCell.delegate = self
                return doneCell
            }
        }
    }
}

extension TasksWithDoneList: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 62)
    }
}

extension TasksWithDoneList: SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        options.expansionStyle = .todoCustom
        
        options.minimumButtonWidth = 67
        options.maximumButtonWidth = 100
        return options
    }
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let item = currentItems?[indexPath.section].items[indexPath.row] else { return nil }
        if orientation == .right {
            var actions: [SwipeAction] = []
            if self.shouldDelete != nil {
                let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionDeletion)
                deleteAction.backgroundColor = .hex("#EF4439")
                deleteAction.image = UIImage(named: "trash")?.withTintColor(UIColor(named: "TAAltBackground")!, renderingMode: .alwaysTemplate)
                deleteAction.hidesWhenSelected = true
                deleteAction.transitionDelegate = ScaleTransition.default
                actions.append(deleteAction)
            }
            
            return actions
        } else if orientation == .left, case .task = item {
            var actions: [SwipeAction] = []
            let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionTick)
            deleteAction.backgroundColor = .hex("#00CE15")
            deleteAction.image = UIImage(named: "check")?.withTintColor(UIColor(named: "TAAltBackground")!, renderingMode: .alwaysTemplate).resize(toWidth: 17)
            deleteAction.hidesWhenSelected = true
            deleteAction.transitionDelegate = ScaleTransition.default
            actions.append(deleteAction)
            
            return actions
        }
        return nil
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, path: IndexPath) {
        guard let item = currentItems?[path.section].items[path.row] else { return }
        switch item {
        case let .task(task), let .doneTask(task):
            shouldDelete?(task)
        }
    }
    func handleSwipeActionTick(action: SwipeAction, path: IndexPath) {
        guard let item = currentItems?[path.section].items[path.row] else { return }
        switch item {
        case let .task(task), let .doneTask(task):
            _ = try! RealmProvider.main.realm.write {
                task.isDone.toggle()
            }
        }

    }
}

extension TasksWithDoneList: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentItems = currentItems else { return }
        let item = currentItems[indexPath.section].items[indexPath.row] // TODO: Somewhy crashes
        switch item {
        case let .task(task):
            onSelected(task)
        case let .doneTask(task):
            _ = try! RealmProvider.main.realm.write {
                task.isDone.toggle()
            }
        }
    }
}

extension TasksWithDoneList {
    enum Model: IdentifiableType, Equatable {
        case task(RlmTask)
        case doneTask(RlmTask)
        
        var identity: String {
            switch self {
            case .task(let task), .doneTask(let task):
                return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
            }
        }
        
        var task: RlmTask {
            switch self {
            case .doneTask(let task), .task(let task):
                return task
            }
        }
    }
}
