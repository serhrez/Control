//
//  Selection1Cell.swift
//  TodoApp
//
//  Created by sergey on 24.11.2020.
//

import Foundation
import UIKit
import Material

class Selection1View: UIView {
    private let textLabel = UILabel()
    private lazy var checkbox = CheckboxView(isStyle2: isStyle2)
    private let isStyle2: Bool
    var onSelected: (() -> Void)? {
        get { checkbox.onSelected }
        set {
            checkbox.onSelected = newValue
        }
    }
    
    func setIsChecked(_ isChecked: Bool) {
        checkbox.configure(isChecked: isChecked)
    }
    
    init(text: String, isSelected: Bool, isStyle2: Bool) {
        self.isStyle2 = isStyle2
        super.init(frame: .zero)
        checkbox.tint = .hex("#447BFE")
        layout(checkbox).leading().centerY()
        checkbox.configure(isChecked: isSelected)
        layout(textLabel).leading(33).top().bottom().trailing()
        textLabel.text = text
        textLabel.font = Fonts.text
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clicked))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func clicked() {
        onSelected?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: -1, height: 24)
    }
}

class Selection2View: UIView {
    private let textLabel = UILabel()
    private lazy var checkbox = CheckboxView(isStyle2: isStyle2)
    private let isStyle2: Bool
    var onSelected: (() -> Void)? {
        get { checkbox.onSelected }
        set {
            checkbox.onSelected = newValue
        }
    }
    
    func setIsChecked(_ isChecked: Bool) {
        checkbox.configure(isChecked: isChecked)
    }
    
    init(text: String, isSelected: Bool, isStyle2: Bool) {
        self.isStyle2 = isStyle2
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        layout(checkbox).leading(15).centerY()
        checkbox.tint = .hex("#447BFE")
        checkbox.configure(isChecked: isSelected)
        
        layout(textLabel).leading(48).top().bottom().trailing()
        textLabel.text = text
        textLabel.font = Fonts.text
        
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "TABorder")!.cgColor
        layer.cornerCurve = .continuous
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clicked))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func clicked() {
        onSelected?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: -1, height: 24)
    }
}
