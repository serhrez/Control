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
    private let viewModel: InboxTasksVcVm = .init()
    private let bag = DisposeBag()
    lazy var tasksWithDoneList: TasksWithDoneList = TasksWithDoneList()
    
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
        view.layout(tasksWithDoneList).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        viewModel
            .tasksSharedObservable
            .filter { !$0.isEmpty }
            .bind(to: tasksWithDoneList.itemsInput)
            .disposed(by: bag)
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
