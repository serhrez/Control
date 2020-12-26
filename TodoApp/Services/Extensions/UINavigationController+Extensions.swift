//
//  UINavigationController+Extensions.swift
//  TodoApp
//
//  Created by sergey on 26.12.2020.
//

import Foundation
import UIKit

extension UIViewController: UIGestureRecognizerDelegate {
    func applySharedNavigationBarAppearance(customOnBack: (() -> Void)? = nil) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.hex("#242424"),
            .font: UIFont.systemFont(ofSize: 22, weight: .bold)
        ]

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
