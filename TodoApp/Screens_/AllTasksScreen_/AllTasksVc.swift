//
//  ViewController.swift
//  TodoApp
//
//  Created by sergey on 07.11.2020.
//

import UIKit
import Motion
import Material
import RxSwift
import RxCocoa
import PopMenu

class AllTasksVc: UIViewController {
    let viewModel: AllTasksVcVM = AllTasksVcVM()
    let tableView = UITableView()
    let tasksToolbar = AllTasksToolbar(frame: .zero)
    let menuButton = IconButton(image: UIImage(named: "menu")?.withTintColor(.black, renderingMode: .alwaysTemplate))
    let searchButton = IconButton(image: UIImage(named: "search")?.withTintColor(.black, renderingMode: .alwaysTemplate))
    let actionsButton = IconButton(image: UIImage(named: "dots")?.withTintColor(.black, renderingMode: .alwaysTemplate))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews() {
        view.backgroundColor = .hex("#F6F6F3")
        setupNavigationBar()
        setupTableView()
        
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(-AllTasksToolbar.estimatedHeight)
    }
    
    func setupTableView() {
        view.layout(tableView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ProjectViewCell.self, forCellReuseIdentifier: ProjectViewCell.reuseIdentifier)
        tableView.register(AddProjectCell.self, forCellReuseIdentifier: AddProjectCell.reuseIdentifier)
        viewModel.initialValues = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.tableUpdates = { [weak self] deletions, insertions, modifications in
            self?.tableView.reloadData()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        view.layout(tasksToolbar).bottomSafe(30)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) { [weak self] in
            self?.view.layoutSubviews()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.titleLabel.text = "All Tasks"

        [menuButton, searchButton, actionsButton].forEach { $0.tintColor = .black }
        actionsButton.addTarget(self, action: #selector(actionsButtonClicked), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonClicked), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuButtonClicked), for: .touchUpInside)
        
        navigationItem.leftViews = [menuButton]
        navigationItem.rightViews = [searchButton, actionsButton]
    }
    
    @objc private func searchButtonClicked() {
        
    }
    
    @objc private func menuButtonClicked() {
    }
    
    // MARK: - POPUP
    @objc private func actionsButtonClicked() {
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "Open Tags", image: UIImage(named: "tag"), didSelect: openTags),
            PopuptodoAction(title: "Sort by name", image: UIImage(named: "switch"), didSelect: sortChange),
            PopuptodoAction(title: "Edit Projects", image: UIImage(named: "adjustments"), didSelect: editProjects)
        ]
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.appearance = .appAppearance
        
        present(popMenu, animated: true)
    }
    
    func openTags(action: PopMenuAction) {
        dismiss(animated: false, completion: nil)
        router.openAllTags()
    }
    
    func sortChange(action: PopMenuAction) {
        
    }
    
    func editProjects(action: PopMenuAction) {
        
    }

    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension AllTasksVc: AppNavigationRouterDelegate { }
extension AllTasksVc: UITableViewDataSource {
    
    func vmIndex(for indexPath: IndexPath) -> Int {
        indexPath.section
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = vmIndex(for: indexPath)
        let model = viewModel.models[index]
        switch model {
        case .addProject:
            let addCell = tableView.dequeueReusableCell(withIdentifier: AddProjectCell.reuseIdentifier, for: indexPath) as! AddProjectCell
            addCell.configure()
            addCell.selectionStyle = .none
            return addCell
        case let .project(project):
            let projectCell = tableView.dequeueReusableCell(withIdentifier: ProjectViewCell.reuseIdentifier, for: indexPath) as! ProjectViewCell
            let progress = viewModel.getProgress(for: project)
            projectCell.configure(icon: project.icon, name: project.name, progress: CGFloat(progress), tasksCount: project.tasks.count, color: project.color)
            projectCell.selectionStyle = .none
            projectCell.motionIdentifier = project.id
            return projectCell
        }
    }
}

extension AllTasksVc: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = vmIndex(for: indexPath)
        let model = viewModel.models[index]
        switch model {
        case .addProject: break
        case let .project(project):
            if project.name == "Inbox" {
                let inboxVc = InboxTasksVc()
                inboxVc.view.motionIdentifier = project.id
                router.debugPushVc(inboxVc, .fade)
            }
        }
    }
}
