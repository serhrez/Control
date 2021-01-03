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
import Typist

class AllProjectsVc: UIViewController {
    let viewModel: AllProjectsVcVM = AllProjectsVcVM()
    let tableView = UITableView()
    lazy var tasksToolbar: AllTasksToolbar = {
        let view = AllTasksToolbar(frame: .zero)
        view.onClick = { [weak self] in
            let project = RealmProvider.main.realm.objects(RlmProject.self).first(where: { $0.name == "Inbox" })!
            let projectDetails = ProjectDetailsVc(project: project, state: .startAddTask)
            self?.router.debugPushVc(projectDetails)
        }
        return view
    }()
    private let keyboard = Typist()
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(menuButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()

    private lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "search"), style: .done, target: self, action: #selector(searchButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()

    private lazy var actionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dots"), style: .done, target: self, action: #selector(actionsButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        setupNavigationBar()
        setupTableView()
//        tasksToolbar.onClick = {
//            self.addTaskModel = .init(priority: .none, name: "", description: "", tags: [], date: nil, reminder: nil, repeatt: nil)
//        }
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
        title = "All Projects"
        
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItems = [actionsButton, searchButton]
    }
    
    @objc private func searchButtonClicked() {
        let searchVc = SearchVc()
        router.debugPushVc(searchVc)
    }
    
    @objc private func menuButtonClicked() {
        let settingsVc = SettingsVc()
        router.debugPushVc(settingsVc)
    }
    
    // MARK: - POPUP
    @objc private func actionsButtonClicked() {
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "Open Tags", image: UIImage(named: "tag"), didSelect: { [weak self] action in
                self?.openTags(action: action)
            }),
            PopuptodoAction(title: "Sort by name", image: UIImage(named: "switch"), didSelect: { [weak self] action in
                self?.sortChange(action: action)
            }),
            PopuptodoAction(title: "Edit Projects", image: UIImage(named: "adjustments"), didSelect: { [weak self] action in
                self?.editProjects(action: action)
            })
        ]
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.appearance = .appAppearance
        
        present(popMenu, animated: true)
    }
    
    func openTags(action: PopMenuAction) {
        dismiss(animated: true, completion: nil)
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

extension AllProjectsVc: AppNavigationRouterDelegate { }
extension AllProjectsVc: UITableViewDataSource {
    
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

extension AllProjectsVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = vmIndex(for: indexPath)
        let model = viewModel.models[index]
        switch model {
        case .addProject:
            let addProject = CreateProjectVc()
            router.debugPushVc(addProject)
        case let .project(project):
            let projectDetails = ProjectDetailsVc(project: project, state: .emptyOrList)
            router.debugPushVc(projectDetails)
        }
    }
}