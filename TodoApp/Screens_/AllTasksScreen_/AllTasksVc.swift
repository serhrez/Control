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
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(menuButtonClicked))
        button.tintColor = .hex("#242424")
        return button
    }()

    private lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "search"), style: .done, target: self, action: #selector(searchButtonClicked))
        button.tintColor = .hex("#242424")
        return button
    }()

    private lazy var actionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dots"), style: .done, target: self, action: #selector(actionsButtonClicked))
        button.tintColor = .hex("#242424")
        return button
    }()

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
        view.layout(tableView).topSafe(20).bottom().leadingSafe(13).trailingSafe(13)
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
        tableView.contentInset = .init(top: 0, left: 0, bottom: 110, right: 0)
        tableView.showsVerticalScrollIndicator = false
        view.layout(gradientView).bottom().leading().trailing().height(216)
    }
    private let gradientView = GradientView()

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        view.layout(tasksToolbar).bottomSafe(30)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) { [weak self] in
            self?.view.layoutSubviews()
        }
    }
    
    private func setupNavigationBar() {
        applySharedNavigationBarAppearance(addBackButton: false)
        title = "All Tasks"
        navigationItem.titleLabel.text = "All Tasks"
        
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItems = [actionsButton, searchButton]
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
        router.openAllTags(mode: .show)
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
        case .addProject:
            let addProject = CreateProjectVc2()
            router.debugPushVc(addProject)
        case let .project(project):
            if project.name == "Inbox" {
                let inboxVc = InboxTasksVc()
                inboxVc.view.motionIdentifier = project.id
                router.debugPushVc(inboxVc, .fade)
            } else {
                let projectDetails = ProjectDetailsVc(project: project)
                router.debugPushVc(projectDetails)
            }
        }
    }
}
