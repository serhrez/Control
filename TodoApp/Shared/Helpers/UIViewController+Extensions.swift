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

extension UIViewController: UIGestureRecognizerDelegate {
    func applySharedNavigationBarAppearance(customOnBack: (() -> Void)? = nil, addBackButton: Bool = true) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.hex("#242424"),
            .font: UIFont.systemFont(ofSize: 22, weight: .bold)
        ]

        if addBackButton {
            // Back Button
            let barButtonItem = UIBarButtonItem(title: "", image: UIImage(named: "chevron-left"), primaryAction: UIAction(handler: { _ in
                if let customOnBack = customOnBack {
                    customOnBack()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }), menu: nil)
            barButtonItem.tintColor = .hex("#242424")
            
            navigationController?.interactivePopGestureRecognizer?.delegate = self
            navigationItem.leftBarButtonItem = barButtonItem
        }
    }
}
