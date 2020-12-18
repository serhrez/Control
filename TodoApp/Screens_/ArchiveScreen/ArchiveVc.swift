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
        collectionView.delegate = self
        flowLayout.minimumLineSpacing = 7
        collectionView.register(ArchiveCell.self, forCellWithReuseIdentifier: ArchiveCell.reuseIdentifier)
        let dataSource = UpdateDiffDataSource<ArchiveVcVm.Model>(collectionView: collectionView) { [unowned self] (collectionView, ip, model) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArchiveCell.reuseIdentifier, for: ip) as! ArchiveCell
            let task = model.task
            let state = model.state
            cell.delegate = self
            cell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasChecklist: !task.subtask.isEmpty, state: state.checkboxState(isTaskDone: task.isDone), clickedWithState: { state in
                viewModel.clickedOnCellCheckbox(item: ip.row, with: state)
            })
            return cell
        }
        collectionView.dataSource = dataSource
        dataSource.updateCell = { cell, ip, model in
            let cell = cell as! ArchiveCell
            cell.update(state: model.state.checkboxState(isTaskDone: model.task.isDone))
        }
        viewModel.models
            .subscribe(dataSource.modelBinding)
            .disposed(by: bag)
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
        deleteAction.backgroundColor = .hex("#EF4439")
        deleteAction.image = UIImage(named: "trash")?.withTintColor(.white, renderingMode: .alwaysTemplate)
        deleteAction.hidesWhenSelected = true
        let restoreAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionRestore)
        restoreAction.backgroundColor = .hex("#FF9900")
        restoreAction.image = UIImage(named: "arrow-back-up")?.resize(toWidth: 24)
        restoreAction.hidesWhenSelected = true
    
        return [deleteAction, restoreAction]
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, path: IndexPath) {
        viewModel.updateState(item: path.item, state: .delete)
    }
    
    func handleSwipeActionRestore(action: SwipeAction, path: IndexPath) {
        viewModel.updateState(item: path.item, state: .restore)
    }
}
extension ArchiveVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 62)
    }
}

extension ArchiveVc: UICollectionViewDelegate {
    
}

extension ArchiveVcVm.State {
    func checkboxState(isTaskDone: Bool) -> CheckboxViewArchive.State {
        switch self {
        case .delete: return .delete
        case .restore: return .restore
        case .none: return isTaskDone ? .checked : .unchecked
        }
    }
}
