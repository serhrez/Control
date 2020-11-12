//
//  AllTagsVc.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import Material

class AllTagsVc: UIViewController {
    let viewModel: AllTagsVcVm = .init()
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .hex("#F6F6F3")
        setupTableView()
        setupNavigationBar()
    }
    func setupTableView() {
        view.layout(tableView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AllTagsTagCell.self, forCellReuseIdentifier: AllTagsTagCell.reuseIdentifier)
        tableView.register(AllTagsAddTagCell.self, forCellReuseIdentifier: AllTagsAddTagCell.reuseIdentifier)
        viewModel.initialValues = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.tableUpdates = { [weak self] deletions, insertions, modifications in
            self?.tableView.reloadData()
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
        
    func setupNavigationBar() {
        navigationItem.titleLabel.text = "Tags"
    }
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension AllTagsVc: AppNavigationRouterDelegate { }
extension AllTagsVc: UITableViewDataSource {
    func vmIndex(for indexPath: IndexPath) -> Int {
        indexPath.section
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 7
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.tags.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = vmIndex(for: indexPath)
        if viewModel.tags.count == index {
            let addCell = tableView.dequeueReusableCell(withIdentifier: AllTagsAddTagCell.reuseIdentifier, for: indexPath) as! AllTagsAddTagCell
            addCell.configure()
            addCell.selectionStyle = .none
            return addCell
        } else {
            let tagCell = tableView.dequeueReusableCell(withIdentifier: AllTagsTagCell.reuseIdentifier, for: indexPath) as! AllTagsTagCell
            let tag = viewModel.tags[index]
            tagCell.configure(name: tag.name, tasksCount: viewModel.allTasksCount(for: tag))
            tagCell.motionIdentifier = tag.id
            tagCell.selectionStyle = .none
            return tagCell
        }
    }
}

extension AllTagsVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = vmIndex(for: indexPath)
        if viewModel.tags.count == index {
            
        } else {
            let tag = viewModel.tags[index]
            
            
        }
    }
}
