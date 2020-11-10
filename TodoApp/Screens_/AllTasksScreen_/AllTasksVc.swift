//
//  ViewController.swift
//  TodoApp
//
//  Created by sergey on 07.11.2020.
//

import UIKit
import Motion

class AllTasksVc: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews() {
        
    }

    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension AllTasksVc: AppNavigationRouterDelegate { }
