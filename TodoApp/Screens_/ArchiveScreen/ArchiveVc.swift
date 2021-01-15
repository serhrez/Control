//
//  ArchiveVc.swift
//  TodoApp
//
//  Created by sergey on 16.12.2020.
//

import Foundation
import UIKit
import RxDataSources
import RxSwift
import SwipeCellKit

final class ArchiveVc: UIViewController {
    private let flowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

    private let viewModel: ArchiveVcVm
    private let bag = DisposeBag()
    
    init(viewModel: ArchiveVcVm) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        view.layout(collectionView).leading(13).trailing(13).topSafe().bottom()
        setupCalendarCollectionView()
        setupNavigationBar()
    }
    
    private func setupCalendarCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        flowLayout.minimumLineSpacing = 7
        collectionView.register(TasksListTaskCell.self, forCellWithReuseIdentifier: TasksListTaskCell.reuseIdentifier)
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<ArchiveVcVm.Model>> { [weak self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            print("cell for row at \(indexPath)")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TasksListTaskCell.reuseIdentifier, for: indexPath) as! TasksListTaskCell
            cell.delegate = self
            guard let task = model.task.task else { return cell }
            cell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, otherTags: task.tags.count >= 2, priority: task.priority, hasChecklist: !task.subtask.isEmpty, onSelected: { print("selected") })
            cell.specialConfigure(isDone: task.isDone)
            return cell
        }
        viewModel.modelsSubject
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }

    private func setupNavigationBar() {
        applySharedNavigationBarAppearance()
        title = "Archive"
    }
    
}

extension ArchiveVc: SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        options.minimumButtonWidth = 67
        options.maximumButtonWidth = 100
        return options
    }
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .default, title: nil, handler: { [weak self] action, path in
            self?.handleSwipeActionRestore(action: action, path: path)
        })
        deleteAction.backgroundColor = .hex("#EF4439")
        deleteAction.image = UIImage(named: "trash")?.withTintColor(UIColor(named: "TAAltBackground")!, renderingMode: .alwaysTemplate)
        deleteAction.hidesWhenSelected = true
        let restoreAction = SwipeAction(style: .default, title: nil, handler: { [weak self] action, path in
            self?.handleSwipeActionRestore(action: action, path: path)
        })
        restoreAction.backgroundColor = .hex("#FF9900")
        restoreAction.image = UIImage(named: "arrow-back-up")?.resize(toWidth: 24)
        restoreAction.hidesWhenSelected = true
    
        return [deleteAction, restoreAction]
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, path: IndexPath) {
        let archived = self.viewModel.archived[path.row]
        let archivedCopy = RlmArchived(value: archived)
        self.viewModel.delete(archived: archived)
    }
    
    func handleSwipeActionRestore(action: SwipeAction, path: IndexPath) {
        let archived = self.viewModel.archived[path.row]
        guard let task = archived.task else { return }
        let taskId = task.id
        let projectId = archived.projectId
        self.viewModel.restoreTask(taskId: taskId)

    }
}
extension ArchiveVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 62)
    }
}

extension ArchiveVc: UICollectionViewDelegate {
    
}
