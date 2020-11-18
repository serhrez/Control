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
    private let animator = UIViewPropertyAnimator()
    var onSelected: (() -> Void)?
    private var isChecked: Bool?
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isChecked: Bool) {
        let previousIsChecked = self.isChecked
        guard self.isChecked != isChecked else { return }
        self.isChecked = isChecked
        changeState(withAnimation: previousIsChecked != nil)
    }
    
    private func setupViews() {
        layout(uncheckedView).edges()
        layout(checkedView).edges()
        layout(SomeControl(onClick: { [unowned self] in self.onSelected?() })).edges()
    }
    private func changeState(withAnimation: Bool) {
        UIView.animate(withDuration: withAnimation ? 0.5 : 0) {
            if self.isChecked ?? false {
                self.checkedView.layer.opacity = 1.0
                self.uncheckedView.layer.opacity = 0
            } else {
                self.checkedView.layer.opacity = 0
                self.uncheckedView.layer.opacity = 1.0
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
