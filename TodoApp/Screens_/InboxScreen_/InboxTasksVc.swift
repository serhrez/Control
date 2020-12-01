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
    private lazy var tableView = UITableView()
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
        view.layout(tableView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TaskCellx1.self, forCellReuseIdentifier: TaskCellx1.reuseIdentifier)
        tableView.register(InboxDoneTaskCell.self, forCellReuseIdentifier: InboxDoneTaskCell.reuseIdentifier)
        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimSection<InboxTasksVcVm.Model>> { [unowned self] (data, tableView, indexPath, model) -> UITableViewCell in
            switch model {
            case let .task(task):
                let taskCell = tableView.dequeueReusableCell(withIdentifier: TaskCellx1.reuseIdentifier, for: indexPath) as! TaskCellx1
                taskCell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasChecklist: !task.subtask.isEmpty) {
                    _ = try! RealmProvider.main.realm.write {
                        task.isDone.toggle()
                    }
                }
                taskCell.selectionStyle = .none

                return taskCell
            case let .doneTask(task):
                let doneCell = tableView.dequeueReusableCell(withIdentifier: InboxDoneTaskCell.reuseIdentifier, for: indexPath) as! InboxDoneTaskCell
                doneCell.configure(text: task.name) {
                    _ = try! RealmProvider.main.realm.write {
                        task.isDone.toggle()
                    }
                }
                doneCell.selectionStyle = .none

                return doneCell
            case let .space(spacing):
                let cell = UITableViewCell()
                cell.heightAnchor.constraint(equalToConstant: spacing).isActive = true
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            }
        }
        
        viewModel.modelsUpdate
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        tableView.delegate = self
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


extension InboxTasksVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.models[indexPath.section].items[indexPath.row]

    }
}
