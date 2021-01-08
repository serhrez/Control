//
//  LaunchScreenManager.swift
//  TodoApp
//
//  Created by sergey on 08.01.2021.
//

import Foundation
import UIKit

class LaunchScreenManager {
    static let instance = LaunchScreenManager(animationDurationBase: 1.3)
    var view: UIView?
    var parentView: UIView?

    let animationDurationBase: Double


    // MARK: - Lifecycle

    init(animationDurationBase: Double) {
        self.animationDurationBase = animationDurationBase
    }
    func animateAfterLaunch(_ parentViewPassedIn: UIView) {
        parentView = parentViewPassedIn
        view = loadView()

        fillParentViewWithView()
        
        animateDisappearing()
    }
    
    func animateDisappearing() {
        guard let view = view,
              let iconView = view.viewWithTag(2) else { return }
        
        UIView.animate(withDuration: 0.4) {
            view.alpha = 0
            iconView.transform = .init(scaleX: 4, y: 4)
        } completion: { _ in
            view.removeFromSuperview()
        }
    }
    func loadView() -> UIView {
        return UINib(nibName: "LaunchScreen", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    func fillParentViewWithView() {
        parentView!.addSubview(view!)

        view!.frame = parentView!.bounds
        view!.center = parentView!.center
    }

}
