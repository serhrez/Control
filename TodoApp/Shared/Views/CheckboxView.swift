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
        uncheckedView.borderColor = .hex("#DFDFDF")
        uncheckedView.layer.borderWidth = 2
        uncheckedView.layer.cornerRadius = 6
        uncheckedView.layer.cornerCurve = .continuous

        return uncheckedView
    }()
    
    private lazy var uncheckedView2: UIView = {
        let uncheckedView = UIView()
        uncheckedView.borderColor = .hex("#447BFE")
        uncheckedView.layer.borderWidth = 2
        uncheckedView.layer.cornerRadius = 6
        uncheckedView.layer.cornerCurve = .continuous
        
        let viewInside = UIView()
        viewInside.layer.cornerRadius = 2
        viewInside.layer.backgroundColor = UIColor.hex("#447BFE").cgColor
        uncheckedView.layout(viewInside).edges(top: 4, left: 4, bottom: 4, right: 4)
        
        return uncheckedView
    }()
    private let checkedViewImage = UIImageView(image: UIImage(named: "checkedsvg")?.withRenderingMode(.alwaysTemplate))
    private let checkedRectangleImage = UIImageView(image: UIImage(named: "checkedrectanglesvg")?.withRenderingMode(.alwaysTemplate))
    private lazy var checkedView: UIView = {
        let checkedView = UIView()
        checkedView.layer.cornerRadius = 6
        checkedView.layer.cornerCurve = .continuous
        checkedView.layout(checkedRectangleImage).edges()
        checkedView.layout(checkedViewImage).edges()
        checkedRectangleImage.tintColor = .hex("#00CE15")

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
            checkedViewImage.tintColor
        }
        set {
            checkedViewImage.tintColor = newValue
            checkedRectangleImage.tintColor = newValue
        }
    }

    init(isStyle2: Bool = false) {
        self.isStyle2 = isStyle2
        super.init(frame: .zero)
        if isStyle2 {
            self.checkedView.backgroundColor = .white//.hex("#447BFE")
            checkedViewImage.tintColor = .blue
        } else {
            checkedViewImage.tintColor = .hex("#00CE15")
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
    
    private func setupViews() {
        layout(uncheckedViewx).edges()
        layout(selectedViewx).edges()
        layout(SomeControl(onClick: { [unowned self] in self.onSelected?() })).edges()
    }
    private func changeState(withAnimation: Bool) {
        if withAnimation {
            UIView.animate(withDuration: 0.5) {
                if self.isChecked ?? false {
                    self.selectedViewx.layer.opacity = 1.0
                    self.uncheckedViewx.layer.opacity = 0
                } else {
                    self.selectedViewx.layer.opacity = 0
                    self.uncheckedViewx.layer.opacity = 1.0
                }
            }
        } else {
            if self.isChecked ?? false {
                self.selectedViewx.layer.opacity = 1.0
                self.uncheckedViewx.layer.opacity = 0
            } else {
                self.selectedViewx.layer.opacity = 0
                self.uncheckedViewx.layer.opacity = 1.0
            }
        }
    }

    class SomeControl: UIControl {
        var onClick: () -> Void
        init(onClick: @escaping () -> Void) {
            self.onClick = onClick
            super.init(frame: .zero)
            addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func touchUp() {
            onClick()
        }
    }
}
