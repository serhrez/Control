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

class AllTasksVc: UIViewController {
    let viewModel: AllTasksVcVM = AllTasksVcVM()
    let tableView = UITableView()
    let tasksToolbar = AllTasksToolbar(frame: .zero)
    
    // MARK: - UI
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(hex: "#F6F6F3")
        setupNavigationBar()
        setupTableView()
        
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(-AllTasksToolbar.estimatedHeight)
    }
    
    func setupTableView() {
        view.layout(tableView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.register(ProjectViewCell.self, forCellReuseIdentifier: ProjectViewCell.reuseIdentifier)
        tableView.register(AddProjectCell.self, forCellReuseIdentifier: AddProjectCell.reuseIdentifier)
        viewModel.tableUpdates = { deletions, insertions, modifications in
            self.tableView.reloadData()
        }
        tableView.dataSource = self
        tableView.delegate = self
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

        let menuButton = IconButton(image: UIImage(named: "menu")?.withTintColor(.black, renderingMode: .alwaysTemplate))
        let searchButton = IconButton(image: UIImage(named: "search")?.withTintColor(.black, renderingMode: .alwaysTemplate))
        let actionsButton = IconButton(image: UIImage(named: "dots")?.withTintColor(.black, renderingMode: .alwaysTemplate))
        [menuButton, searchButton, actionsButton].forEach { $0.tintColor = .black }

        navigationItem.leftViews = [menuButton]
        navigationItem.rightViews = [searchButton, actionsButton]
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
        viewModel.projects.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = vmIndex(for: indexPath)
        if viewModel.projects.count == index {
            let addCell = tableView.dequeueReusableCell(withIdentifier: AddProjectCell.reuseIdentifier, for: indexPath) as! AddProjectCell
            addCell.configure()
            addCell.selectionStyle = .none
            return addCell
        } else {
            let projectCell = tableView.dequeueReusableCell(withIdentifier: ProjectViewCell.reuseIdentifier, for: indexPath) as! ProjectViewCell
            let project = viewModel.projects[index]
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
        if viewModel.projects.count == index {
            
        } else {
            let project = viewModel.projects[index]
            
            let detailsVc = ProjectDetailsVc()
            detailsVc.view.motionIdentifier = project.id
            router.debugPushVc(detailsVc, .fade)

        }
    }
}
