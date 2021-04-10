//
//  CustomFloatingPanel.swift
//  TodoApp
//
//  Created by sergey on 10.04.2021.
//

import Foundation
import UIKit
import FloatingPanel

class CustomFloatingPanel {
    var fpc: FloatingPanelController = FloatingPanelController()
    init() {
    }
    
    func configure(vc: UIViewController & ContentHeightProtocol, scrollViews: [UIScrollView]) {
        fpc = FloatingPanelController()
        fpc.layout = CustomFloatingPanelLayout(contentHeight: vc.height())
        fpc.surfaceView.appearance.cornerRadius = 16
        fpc.set(contentViewController: vc)
        for scrollView in scrollViews {
            fpc.track(scrollView: scrollView)
        }
        fpc.isRemovalInteractionEnabled = true
        let backDropTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdropGesture))
        fpc.backdropView.addGestureRecognizer(backDropTapGesture)
        vc.view.layoutSubviews()
    }
    
    @objc func handleBackdropGesture(tapGesture: UITapGestureRecognizer) {
        fpc.dismiss(animated: true, completion: nil)
    }
}

fileprivate class CustomFloatingPanelLayout: FloatingPanelLayout {
    private let contentHeight: CGFloat
    init(contentHeight: CGFloat) {
        self.contentHeight = contentHeight
    }
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: max(max(UIScreen.main.bounds.height - contentHeight, 0), 15), edge: .top, referenceGuide: .safeArea)
        ]
    }
}

protocol ContentHeightProtocol {
    func height() -> CGFloat
}
