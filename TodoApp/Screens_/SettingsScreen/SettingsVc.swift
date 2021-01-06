//
//  SettingsVc.swift
//  TodoApp
//
//  Created by sergey on 27.12.2020.
//

import Foundation
import UIKit
import Material

class SettingsVc: UIViewController {
    var popTransition = SlidePopTransition()
    lazy var mainCollectionView = SettingsVcCollectionView(
        items: [
            .init(text: "Premium Features", imageName: "premiumfire", imageWidth: 12, onClick: { [weak self] in
                guard let self = self else { return }
                
            }),
            .init(text: "Archive", imageName: "archive", imageWidth: 20, onClick: { [weak self] in
                guard let self = self else { return }
                self.router.openArchive()
            })
        ])
    lazy var secondaryCollectionView = SettingsVcCollectionView(
        items: [
            .init(text: "Recommend to Friends", imageName: "recommendheart", imageWidth: 16.35, onClick: { [weak self] in
                guard let self = self else { return }
                
            }),
            .init(text: "Feedback & Suggestions", imageName: "feedback", imageWidth: 18, onClick: { [weak self] in
                guard let self = self else { return }
                
            })
        ])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TABackground")
        applySharedNavigationBarAppearance(popGesture: false)
        title = "Settings"
        
        view.layout(mainCollectionView).topSafe(15).leading(13).trailing(13).bottomSafe()
        mainCollectionView.collectionView.isScrollEnabled = false
        view.layout(secondaryCollectionView).bottomSafe(15).leading(13).trailing(13).height(133)
        secondaryCollectionView.collectionView.isScrollEnabled = false
        setupPopTransition()
    }
    
    // MARK: - Pop transition
    func setupPopTransition() {
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(didPan))
        edgeGesture.edges = .right
        view.addGestureRecognizer(edgeGesture)
    }
    
    @objc func didPan(gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began:
            popTransition.isInteractive = true
            navigationController?.popViewController(animated: true)
        case .ended, .cancelled:
            popTransition.isInteractive = false
        default: break
        }
        popTransition.handlePan(gesture)
    }
    
    var didDisappear: () -> Void = { }
    deinit { didDisappear() }
}

extension SettingsVc: AppNavigationRouterDelegate { }

extension SettingsVc: TATransitionProvider {
    func pushTransitioning(from vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlidePushTransition()
    }
    
    func popTransitioning(from vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return popTransition
    }
    func interactionController(for animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return popTransition.isInteractive ? popTransition : nil
    }
}
