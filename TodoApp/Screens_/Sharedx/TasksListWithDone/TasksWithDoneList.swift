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
    private let collectionLayout: UICollectionViewLayout = {
        UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection? in
            if section == 0 {
                let interLineSpacing: CGFloat = 7
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(62 + interLineSpacing))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = .init(top: 0, leading: 0, bottom: interLineSpacing, trailing: 0)
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else {
                let interLineSpacing: CGFloat = 45
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(24 + interLineSpacing))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = .init(top: interLineSpacing / 2, leading: 0, bottom: interLineSpacing / 2, trailing: 0)
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
        }
    }()
    private lazy var tableView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    private lazy var dataSource: DataSource = makeDataSource()
    private let bag = DisposeBag()
    private let onSelected: (RlmTask) -> Void
    private let shouldDelete: ((RlmTask) -> Void)?
    private var currentItems: [AnimSection<Model>]?
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
        layout(tableView).edges()
        layout(gradientView).bottom().leading().trailing().height(216)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(TasksListTaskCell.self, forCellWithReuseIdentifier: TasksListTaskCell.reuseIdentifier)
        tableView.register(DoneTasksListTaskCell.self, forCellWithReuseIdentifier: DoneTasksListTaskCell.reuseIdentifier)
        tableView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "separator")
        tableView.delegate = self
        itemsInput.map { tasks -> [AnimSection<Model>] in
            let section1 = tasks.filter { !$0.isDone }.map { TasksWithDoneList.Model.task($0) }
            var section2 = tasks.filter { $0.isDone }.map { TasksWithDoneList.Model.doneTask($0) }
            if !section1.isEmpty {
                section2.insert(.space, at: 0)
            }
            return [AnimSection(items: section1), AnimSection(identity: "wewqe", items: section2)]
        }
        .do(onNext: { [weak self] in
            self?.currentItems = $0
        })
        .bind(to: tableView.rx.items(dataSource: dataSource))
        .disposed(by: bag)
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
                return doneCell
            case .space:
                let cell = tableView.dequeueReusableCell(withReuseIdentifier: "separator", for: indexPath)
                cell.backgroundColor = .clear
                return cell
            }
        }
    }
}

extension TasksWithDoneList: SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        options.expansionStyle = .fill
        
        
        options.minimumButtonWidth = 67
        options.maximumButtonWidth = 100
        return options
    }
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            var actions: [SwipeAction] = []
            if self.shouldDelete != nil {
                let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionDeletion)
                deleteAction.backgroundColor = .hex("#EF4439")
                deleteAction.image = UIImage(named: "trash")?.withTintColor(.white, renderingMode: .alwaysTemplate)
                deleteAction.hidesWhenSelected = true
                actions.append(deleteAction)
            }
            
            return actions
        } else if orientation == .left {
            var actions: [SwipeAction] = []
            let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionTick)
            deleteAction.backgroundColor = .hex("#447BFE")
            deleteAction.image = UIImage(named: "recommendheart")?.withTintColor(.white, renderingMode: .alwaysTemplate)
            deleteAction.hidesWhenSelected = true
            actions.append(deleteAction)
            
            return actions
        }
        return nil
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, path: IndexPath) {
        guard let item = currentItems?[path.section].items[path.row] else { return }
        switch item {
        case let .task(task):
            shouldDelete?(task)
        default: break
        }
    }
    func handleSwipeActionTick(action: SwipeAction, path: IndexPath) {
        guard let item = currentItems?[path.section].items[path.row] else { return }
        switch item {
        case let .task(task):
            _ = try! RealmProvider.main.realm.write {
                task.isDone.toggle()
            }
        default: break
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
        default: break
        }
    }
}

extension TasksWithDoneList {
    enum Model: IdentifiableType, Equatable {
        case task(RlmTask)
        case doneTask(RlmTask)
        case space
        
        var identity: String {
            switch self {
            case .task(let task), .doneTask(let task):
                return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
            case .space:
                return "space" // Should be only one space for collection
            }
        }
    }
}
