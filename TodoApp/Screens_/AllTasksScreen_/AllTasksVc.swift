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
        
        let textField = UITextField()
        
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(-AllTasksToolbar.estimatedHeight)
    }
    
//    func setupStackView() {
        //        let stackView = UIStackView(arrangedSubviews: [
        //            ProjectViewCell(icon: .assetImage("Image"), name: "Inbox", progress: 0.2, tasksCount: 4, color: UIColor(hex: "#571CFF")!),
        //            ProjectViewCell(icon: .text("🚒"), name: "Work", progress: 0.75, tasksCount: 77, color: .systemGreen),
        //            ProjectViewCell(icon: .text("🏝"), name: "Happy Weekend", progress: 0.85, tasksCount: 7, color: .systemBlue)
        //        ])
        //        stackView.spacing = 7
        //        stackView.axis = .vertical
        //        view.layout(stackView).center().leading(16).trailing(16)
//    }
    
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
