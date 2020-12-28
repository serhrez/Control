//
//  CheckboxView.swift
//  TodoApp
//
//  Created by sergey on 16.11.2020.
//

import Foundation
import UIKit
import Material

class AutoselectCheckboxView: UIView {
    private let uncheckedView: UIView = {
        let uncheckedView = UIView()
        uncheckedView.borderColor = .hex("#DFDFDF")
        uncheckedView.layer.borderWidth = 2
        uncheckedView.layer.cornerRadius = 6
        uncheckedView.layer.cornerCurve = .continuous

        return uncheckedView
    }()
    private let checkedView: UIView = {
        let checkedView = UIView()
        checkedView.backgroundColor = .hex("#00CE15")
        checkedView.layer.cornerRadius = 6
        checkedView.layer.cornerCurve = .continuous
        checkedView.layout(UIImageView(image: UIImage(named: "checkbox-ok"))).edges()

        return checkedView
    }()
    private lazy var onClickControl: OnClickControl = {
        let onClickControl = OnClickControl(onClick: { [unowned self] touchDown in
            guard touchDown else { return }
            self.isChecked.toggle()
            self.changeState(withAnimation: true)
            self.onSelected?(self.isChecked)
        })
        onClickControl.pointInsideInsets = .init(top: 15, left: 10, bottom: 15, right: 10)
        return onClickControl
    }()
    var onSelected: ((Bool) -> Void)?
    private(set) var isChecked: Bool = false
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isChecked: Bool) {
        self.isChecked = isChecked
        changeState(withAnimation: false)
    }
    
    func configure(priority: Priority) {
        switch priority {
        case .high: uncheckedView.borderColor = .hex("#EF4439")
        case .medium: uncheckedView.borderColor = .hex("#FF9900")
        case .low: uncheckedView.borderColor = .hex("#447BFE")
        case .none: uncheckedView.borderColor = .hex("#DFDFDF")
        }
    }
    
    private func setupViews() {
        layout(uncheckedView).edges()
        layout(checkedView).edges()
        layout(onClickControl).edges()
    }
    private func changeState(withAnimation: Bool) {
        func changeState() {
            if self.isChecked {
                self.checkedView.layer.opacity = 1.0
                self.uncheckedView.layer.opacity = 0
            } else {
                self.checkedView.layer.opacity = 0
                self.uncheckedView.layer.opacity = 1.0
            }
        }
        if withAnimation {
            UIView.animate(withDuration: 0.5) {
                changeState()
            }
        } else {
            changeState()
        }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return onClickControl.hitTest(point, with: event)
    }
}
