//
//  AccessoryView.swift
//  TodoApp
//
//  Created by sergey on 18.03.2021.
//

import Foundation
import UIKit
import Material

class AccessoryView: UIView {
    
    private let hideKeyboardButton: NewCustomButton = {
        let hideKeyboardButton = NewCustomButton(type: .custom)
        hideKeyboardButton.pointInsideInsets = .init(top: 15, left: 15, bottom: 15, right: 15)
        hideKeyboardButton.opacityState = .opacity()
        hideKeyboardButton.transformState = .transformScale()
    
        return hideKeyboardButton
    }()
    
    private let doneButton: NewCustomButton = {
        let button = NewCustomButton(type: .custom)
        button.pointInsideInsets = .init(top: 15, left: 15, bottom: 15, right: 15)
        button.opacityState = .opacity()
        button.transformState = .transformScale()
        let doneLabel = UILabel()
        doneLabel.text = "Done".localizable()
        doneLabel.font = Fonts.heading4
        doneLabel.textColor = .hex("#447bfe")
        button.layout(doneLabel).edges()
        return button
    }()
    
    let onDone: () -> Void
    let onHide: () -> Void
    
    init(onDone: @escaping () -> Void, onHide: @escaping () -> Void) {
        self.onDone = onDone
        self.onHide = onHide
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
        self.backgroundColor = UIColor(named: "TAPremSpecial1")
        setupViews()
    }
    
    private func setupViews() {
        let image = UIImage(systemName: "keyboard.chevron.compact.down")!
        let imageView = UIImageView(image: image)
        hideKeyboardButton.layout(imageView).edges()
        layout(hideKeyboardButton).leading(20).centerY(-1).height(image.height).width(image.width)
        layout(doneButton).trailing(21).top(12).bottom(12)
        let borderLine = UIView()
        borderLine.backgroundColor = UIColor(named: "TABorder")
        layout(borderLine).top().height(1).leading().trailing()
        hideKeyboardButton.addTarget(self, action: #selector(hideKeyboardClicked), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
    }
    
    @objc func hideKeyboardClicked() {
        onHide()
    }
    
    @objc func doneClicked() {
        onDone()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
