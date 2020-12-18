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
        view.backgroundColor = .hex("#F6F6F3")
        view.layout(collectionView).leading(13).trailing(13).topSafe(30).bottom()
        setupCalendarCollectionView()
        setupNavigationBar()
    }
    
    private func setupCalendarCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        flowLayout.minimumLineSpacing = 7
        collectionView.delegate = self
        collectionView.register(ArchiveCell.self, forCellWithReuseIdentifier: ArchiveCell.reuseIdentifier)
        collectionView.dataSource = self
    }

    private func setupNavigationBar() {
        navigationItem.titleLabel.text = "Archive"
        
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
        let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionDeletion)
//        deleteAction.
        deleteAction.backgroundColor = .hex("#EF4439")
        deleteAction.image = UIImage(named: "trash")?.withTintColor(.white, renderingMode: .alwaysTemplate)
        deleteAction.hidesWhenSelected = true
        let restoreAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionRestore)
        restoreAction.backgroundColor = .hex("#FF9900")
        restoreAction.image = UIImage(named: "arrow-back-up")?.resize(toWidth: 24)
        restoreAction.hidesWhenSelected = true
    
        return [deleteAction, restoreAction]
//        return []
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, path: IndexPath) {
        let item = viewModel.models[0].items[path.item]
        viewModel.models[0].items[path.item] = .init(task: item.task, state: .delete)
        if let cell = collectionView.cellForItem(at: path) as? ArchiveCell {
            cell.update(state: .delete)
        }
    }
    
    func handleSwipeActionRestore(action: SwipeAction, path: IndexPath) {
        let item = viewModel.models[0].items[path.item]
        viewModel.models[0].items[path.item] = .init(task: item.task, state: .restore)
        
        if let cell = collectionView.cellForItem(at: path) as? ArchiveCell {
            cell.update(state: .restore)
        }
    }
}
extension ArchiveVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 62)
    }
}

extension ArchiveVc: UICollectionViewDelegate {
    
}

extension ArchiveVc: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.models[0].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = viewModel.models[0].items[indexPath.item]
        let task = model.task
        let state = model.state
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArchiveCell.reuseIdentifier, for: indexPath) as! ArchiveCell
        cell.delegate = self
        cell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasChecklist: !task.subtask.isEmpty, state: state.checkboxState(isTaskDone: task.isDone)) { fromState in
            switch fromState {
            case .checked:
                return .unchecked
            case .unchecked:
                return .checked
            case .delete:
                return fromState
            case .restore:
                return fromState
            }
        }
        return cell

    }
}

extension ArchiveVcVm.State {
    func checkboxState(isTaskDone: Bool) -> AutoselectCheckboxViewArchive.State {
        switch self {
        case .delete: return .delete
        case .restore: return .restore
        case .none: return isTaskDone ? .checked : .unchecked
        }
    }
}
