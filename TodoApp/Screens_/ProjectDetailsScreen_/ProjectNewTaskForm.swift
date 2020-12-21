//
//  ProjectNewTaskForm.swift
//  TodoApp
//
//  Created by sergey on 21.12.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

class ProjectNewTaskForm: UIView {
    let onCalendarClicked: (UIView) -> Void
    let onTagClicked: (UIView) -> Void
    let onPriorityClicked: (UIView) -> Void
    init(onCalendarClicked: @escaping (UIView) -> Void,
         onTagClicked: @escaping (UIView) -> Void,
         onPriorityClicked: @escaping (UIView) -> Void) {
        self.onCalendarClicked = onCalendarClicked
        self.onTagClicked = onTagClicked
        self.onPriorityClicked = onPriorityClicked
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
        backgroundColor = .hex("#ffffff")
        layer.cornerRadius = 16
        layout(calendarButton).leading(25).bottom(18).width(25).height(25)
        layout(tagButton).leading(calendarButton.anchor.trailing, 25).bottom(18).width(25).height(25)
        layout(priorityButton).leading(tagButton.anchor.trailing, 25).bottom(18).width(25).height(25)
    }
    
    let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        return stackView
    }()
    
    let checkbox = CheckboxView()
    let nameField: UITextField = {
        let textField = UITextField()

        textField.font = .systemFont(ofSize: 20, weight: .medium)
        textField.textColor = .hex("#242424")
        let attributes = Attributes().font(UIFont.systemFont(ofSize: 20, weight: .medium))
        textField.attributedPlaceholder = "Call to John Wick?".at.attributed(with: attributes.foreground(color: .hex("#a4a4a4")))
        return textField
    }()
    lazy var calendarButton: ImageButton = {
        let simpleButton = ImageButton(type: .custom)
        simpleButton.imageName = "calendar-plus"
        simpleButton.imageWidth = 16
        simpleButton.configureImage()
        simpleButton.tintColor = .hex("#a4a4a4")
        simpleButton.addTarget(self, action: #selector(calendarClicked), for: .touchUpInside)
        return simpleButton
    }()
    @objc func calendarClicked() {
        onCalendarClicked(calendarButton)
    }
    lazy var tagButton: ImageButton = {
        let simpleButton = ImageButton(type: .custom)
        simpleButton.imageName = "tag"
        simpleButton.imageWidth = 17.38
        simpleButton.configureImage()
        simpleButton.tintColor = .hex("#a4a4a4")
        simpleButton.addTarget(self, action: #selector(tagClicked), for: .touchUpInside)
        return simpleButton
    }()
    @objc func tagClicked() {
        onTagClicked(tagButton)
    }
    lazy var priorityButton: ImageButton = {
        let simpleButton = ImageButton(type: .custom)
        simpleButton.imageName = "flag"
        simpleButton.imageWidth = 14
        simpleButton.configureImage()
        simpleButton.tintColor = .hex("#a4a4a4")
        simpleButton.addTarget(self, action: #selector(priorityClicked), for: .touchUpInside)
        return simpleButton
    }()
    @objc func priorityClicked() {
        onPriorityClicked(priorityButton)
    }
    

    lazy var taskDescription: MyGrowingTextView = {
        let textView = MyGrowingTextView(placeholderText: "Need to add notes?")
        textView.growingTextFieldDelegate = self
        let attributes = Attributes().lineSpacing(5).foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 16, weight: .regular))
        textView.placeholderAttrs = attributes
        textView.textFieldAttrs = attributes

        return textView
    }()
}

extension ProjectNewTaskForm: UITextViewDelegate {
    
}

class ImageButton: SimpleButton {
    
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    var imageName: String = ""
    var imageWidth: CGFloat = 18
    func configureImage() {
        let image = UIImage(named: imageName)?.resize(toWidth: imageWidth)?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
        imageView?.contentMode = .scaleAspectFit
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureButtonStyles() {
        super.configureButtonStyles()
        setScale(0.95, for: .highlighted)
    }
}
