//
//  AutoselectCheckboxViews.swift
//  TodoApp
//
//  Created by sergey on 16.12.2020.
//

import Foundation
import UIKit
import Material


class AutoselectCheckboxViewArchive: AutoselectCheckboxViewBase {
    private let uncheckedView: UIView = {
        let uncheckedView = UIView()
        uncheckedView.borderColor = .hex("#DFDFDF")
        uncheckedView.layer.borderWidth = 2
        uncheckedView.layer.cornerRadius = 6
        uncheckedView.layer.cornerCurve = .continuous

        return uncheckedView
    }()
    private lazy var checkedView: UIView = getView(imageName: "checkbox-ok", color: .hex("#00CE15"))
    private lazy var deleteView: UIView = UIImageView(image: UIImage(named: "closebutton"))
    private lazy var restoreView: UIView = getView(imageName: "restore", color: .hex("#FF9900"))
    private(set) var state: State = .unchecked
    var onStateChanged: (State) -> State = { _ in .unchecked }
    
    init() {
        super.init(frame: .zero)
        viewsToLayout = [uncheckedView, checkedView, deleteView, restoreView]
        baseOnSelected = { [weak self] in
            guard let self = self else { return false }
            let previousState = self.state
            self.state = self.onStateChanged(self.state)
            return previousState != self.state
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(state: State) {
        self.state = state
        setupState()
    }
    
    override func setupState() {
        uncheckedView.layer.opacity = 0
        checkedView.layer.opacity = 0
        deleteView.layer.opacity = 0
        restoreView.layer.opacity = 0
        switch state {
        case .unchecked: uncheckedView.layer.opacity = 1
        case .checked: checkedView.layer.opacity = 1
        case .restore: restoreView.layer.opacity = 1
        case .delete: deleteView.layer.opacity = 1
        }
    }
    
    private func getView(imageName: String, color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.layout(UIImageView(image: UIImage(named: imageName))).edges()
        return view
    }
    enum State {
        case checked
        case unchecked
        case delete
        case restore
    }
}


class AutoselectCheckboxViewBase: UIView {
    fileprivate var baseOnSelected: (() -> Bool) = { false }
    private var onClickControl: OnClickControl?
    fileprivate var viewsToLayout: [UIView] = [] {
        willSet {
            onClickControl?.removeFromSuperview()
            viewsToLayout.forEach { $0.removeFromSuperview() }
            for view in newValue {
                layout(view).edges()
            }
            layout(OnClickControl(onClick: { [unowned self] touchDown in
                guard touchDown else { return }
                if baseOnSelected() {
                    changeState(withAnimation: true)
                }
            })).edges()
        }
    }
    
    fileprivate func setupState() {
    }
    
    private func changeState(withAnimation: Bool) {
        if withAnimation {
            UIView.animate(withDuration: 0.5) {
                self.setupState()
            }
        } else {
            setupState()
        }
    }
}
