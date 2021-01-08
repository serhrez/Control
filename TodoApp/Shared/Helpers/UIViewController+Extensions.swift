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
    func applySharedNavigationBarAppearance(customOnBack: (() -> Void)? = nil, addBackButton: Bool = true, popGesture: Bool = true) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(named: "TAHeading")!,
            .font: UIFont.systemFont(ofSize: Constants.navigationTitleFontSize, weight: .bold)
        ]

        if addBackButton {
            // Back Button
            let barButtonItem = UIBarButtonItem(title: "", image: UIImage(named: "chevron-left"), primaryAction: UIAction(handler: { [weak self] _ in
                if let customOnBack = customOnBack {
                    customOnBack()
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }), menu: nil)
            barButtonItem.tintColor = UIColor(named: "TAHeading")!
            navigationItem.leftBarButtonItem = barButtonItem
        }
        navigationController?.interactivePopGestureRecognizer?.delegate = addBackButton && popGesture ? self : NilDelegate()
    }
}

fileprivate class NilDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}
