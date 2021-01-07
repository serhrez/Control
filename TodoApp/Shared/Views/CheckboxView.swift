//
//  CheckboxView.swift
//  TodoApp
//
//  Created by sergey on 16.11.2020.
//

import Foundation
import UIKit
import Material

class CheckboxView: UIView {
    private lazy var uncheckedView: UIView = {
        let uncheckedView = UIView()
        uncheckedView.borderColor = UIColor(named: "TABorder")!
        uncheckedView.layer.borderWidth = 2
        uncheckedView.layer.cornerRadius = 6
        uncheckedView.layer.cornerCurve = .continuous

        return uncheckedView
    }()
    private let __uncheckedView = UIView()
    private lazy var uncheckedView2: UIView = {
        __uncheckedView.layer.borderWidth = 2
        __uncheckedView.layer.cornerRadius = 6
        __uncheckedView.layer.cornerCurve = .continuous
        
        let viewInside = UIView()
        viewInside.layer.cornerRadius = 2
        viewInside.backgroundColor = UIColor.hex("#447BFE")
        __uncheckedView.layout(viewInside).edges(top: 4, left: 4, bottom: 4, right: 4)
        
        return __uncheckedView
    }()
    private let checkedViewImage = UIImageView(image: UIImage(named: "check"))
    private lazy var checkedView: UIView = {
        let checkedView = UIView()
        checkedView.layer.cornerRadius = 6
        checkedView.layer.cornerCurve = .continuous
        
        checkedView.layout(checkedViewImage).center().width(11).height(8)
        checkedView.backgroundColor = .hex("#00CE15")

        return checkedView
    }()
    private let animator = UIViewPropertyAnimator()
    var onSelected: (() -> Void)?
    private var isChecked: Bool?
    private let isStyle2: Bool
    
    private var selectedViewx: UIView {
        checkedView
    }
    private var uncheckedViewx: UIView {
        isStyle2 ? uncheckedView2 : uncheckedView
    }
    var tint: UIColor {
        get {
            checkedView.tintColor
        }
        set {
            checkedView.backgroundColor = newValue
        }
    }

    init(isStyle2: Bool = false) {
        self.isStyle2 = isStyle2
        super.init(frame: .zero)
        if isStyle2 {
            checkedView.backgroundColor = .hex("#447BFE")
        } else {
            checkedView.backgroundColor = .hex("#00CE15")
        }
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(priority: Priority) {
        uncheckedView.borderColor = priority.color
    }
    
    func configure(isChecked: Bool) {
        let previousIsChecked = self.isChecked
        guard self.isChecked != isChecked else { return }
        self.isChecked = isChecked
        changeState(withAnimation: previousIsChecked != nil)
    }
    lazy var control = OnClickControl(onClick: { [weak self] isSelected in
        if isSelected {
            self?.onSelected?()
        }
    })

    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        __uncheckedView.layer.borderColor = UIColor.hex("#447BFE").cgColor
    }
    
    private func setupViews() {
        layout(uncheckedViewx).edges().width(22).height(22)
        layout(selectedViewx).edges().width(22).height(22)
        control.pointInsideInsets = .init(top: 15, left: 10, bottom: 15, right: 10)
        layout(control).edges().width(22).height(22)
    }
    private func changeState(withAnimation: Bool) {
        func apply() {
            if self.isChecked ?? false {
                self.selectedViewx.layer.opacity = 1.0
                self.uncheckedViewx.layer.opacity = 0
            } else {
                self.selectedViewx.layer.opacity = 0
                self.uncheckedViewx.layer.opacity = 1.0
            }
        }
        if withAnimation {
            UIView.animate(withDuration: 0.5) {
                apply()
            }
        } else {
            apply()
        }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        onSelected != nil ? control.hitTest(point, with: event) : nil
    }

}
