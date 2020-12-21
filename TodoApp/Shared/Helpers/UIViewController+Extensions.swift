//
//  UIViewController+Extensions.swift
//  TodoApp
//
//  Created by sergey on 21.12.2020.
//

import Foundation
import UIKit

extension UIViewController {
    func addChildPresent(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func addChildDismiss() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
