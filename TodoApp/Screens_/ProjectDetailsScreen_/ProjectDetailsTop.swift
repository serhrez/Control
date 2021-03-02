//
//  ProjectDetailsTop.swift
//  TodoApp
//
//  Created by sergey on 21.12.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib
import SnapKit

class ProjectDetailsTop: UIView {
    
    var color: UIColor {
        didSet {
            colorCircle.circleColor = color
        }
    }
    var icon: Icon {
        didSet {
            clickableIcon.iconView.configure(icon)
        }
    }
    let shouldAnimate: () -> Bool
    let onProjectNameChanged: (String) -> Void
    let iconSelected: () -> Void
    let onColorSelected: (_ sourceView: UIView, _ selectedColor: UIColor) -> Void
    var shouldLayoutSubviews: () -> Void = { }
    
    init(color: UIColor, projectName: String, icon: Icon, onProjectNameChanged: @escaping (String) -> Void, onProjectDescriptionChanged: @escaping (String) -> Void, colorSelection: @escaping (_ sourceView: UIView, _ selectedColor: UIColor) -> Void, iconSelected: @escaping () -> Void, shouldAnimate: @escaping () -> Bool) {
        self.icon = icon
        self.color = color
        self.onProjectNameChanged = onProjectNameChanged
        self.onColorSelected = colorSelection
        self.iconSelected = iconSelected
        self.shouldAnimate = shouldAnimate
        super.init(frame: .zero)
        self.projectNameField.text = projectName
        setupViews()
    }
    
    func addShadowFromOutside() {
        addShadow(offset: .init(width: 0, height: 2), opacity: 1, radius: 16, color: UIColor(red: 0.141, green: 0.141, blue: 0.141, alpha: 0.1))
    }
    
    func setupViews() {
        backgroundColor = UIColor(named: "TAAltBackground")!
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layout(scrollView).edges().height(88)
        scrollView.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        scrollView.layout(colorCircle).leading(28).top(33)
        scrollView.layout(projectNameField).leading(colorCircle.anchor.trailing, 13).centerY(colorCircle.anchor.centerY).trailing(28)
        layout(clickableIcon).top(-58 / 2).centerX()
    }
    
    private func colorSelection() {
        onColorSelected(colorCircle, color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let scrollView = UIScrollView()
    private lazy var projectNameField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.heading1
        textField.textColor = UIColor(named: "TAHeading")!
        textField.delegate = self
        textField.attributedPlaceholder = "New Project".localizable().at.attributed { attr in
            attr.foreground(color: UIColor(named: "TASubElement")!).font(Fonts.heading1)
        }
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }()
    
    private lazy var colorCircle: GappedCircle = {
        let circle = GappedCircle(circleColor: color, widthHeight: 22)
        circle.onClick = { [weak self] in
            self?.colorSelection()
        }
        circle.configure(isSelected: true, animated: false)
        return circle
    }()
    
    private lazy var clickableIcon: ClickableIconView = {
        let iconView = ClickableIconView(onClick: iconSelected)
        iconView.iconView.iconFontSize = 58
        iconView.iconView.configure(icon)
        iconView.widthAnchor.constraint(equalToConstant: 58).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 58).isActive = true
        return iconView
    }()
    func navBarClicked(point: CGPoint) {
        if clickableIcon.point(inside: clickableIcon.convert(point, from: nil), with: nil) {
            iconSelected()
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return super.point(inside: point, with: event)
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let superHitTest = super.hitTest(point, with: event)
        return superHitTest ?? clickableIcon.hitTest(point, with: event)
    }
}
extension ProjectDetailsTop: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case projectNameField:
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            return true
        default: break
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case projectNameField:
            if let name = projectNameField.text { onProjectNameChanged(name) }
        default: break
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
