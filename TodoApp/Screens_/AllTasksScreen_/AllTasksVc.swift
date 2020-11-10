//
//  ViewController.swift
//  TodoApp
//
//  Created by sergey on 07.11.2020.
//

import UIKit
import Motion
import Material

class AllTasksVc: UIViewController {
    
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
        
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(-AllTasksToolbar.estimatedHeight)
        view.layout(AddProjectCell()).center()
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

        let menuButton = IconButton(image: Material.Icon.cm.menu?.withTintColor(.black, renderingMode: .alwaysTemplate))
        let searchButton = IconButton(image: Material.Icon.cm.search?.withTintColor(.black, renderingMode: .alwaysTemplate))
        let actionsButton = IconButton(image: Material.Icon.cm.edit?.withTintColor(.black, renderingMode: .alwaysTemplate))
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
