//
//  ProjectDetailsVc.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit

class ProjectDetailsVc: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension ProjectDetailsVc: AppNavigationRouterDelegate { }
