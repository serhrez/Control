//
//  AppNavigationController.swift
//  TodoApp
//
//  Created by sergey on 10.11.2020.
//

import Foundation
import UIKit
import Motion
import Material

class AppNavigationController: NavigationController {
    
    override func prepare() {
        super.prepare()
        isMotionEnabled = true
        guard let navBar = navigationBar as? NavigationBar else { return }
        navBar.isTranslucent = true
    }
}
