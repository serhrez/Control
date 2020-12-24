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
import ResizingTokenField
import SwiftDate

class ProjectNewTaskForm: UIView {
    let shouldAnimate: () -> Bool
    let onCalendarClicked: (UIView) -> Void
    let onTagClicked: (UIView) -> Void
    let onPriorityClicked: (UIView) -> Void
    let onTagPlusClicked: () -> Void
    var shouldLayoutSubviews: () -> Void = { }
    var shouldCreateTask: ((ProjectDetailsTaskCreateModel) -> Void)
    override func becomeFirstResponder() -> Bool {
        return nameField.becomeFirstResponder()
    }
    // MARK: - Inputs
    var date: (Date?, Reminder?, Repeat?) = (nil,nil,nil) {
        didSet {
            let datee = date.0
            let reminder = date.1
            let repeatt = date.2
            if let date = datee {
                dateDetailLabel.configure(with: DateFormatter.str(from: date))
                dateDetailLabel.isHidden = false
            } else {
                dateDetailLabel.isHidden = true
            }
            if let reminder = reminder {
                reminderDetailLabel.configure(with: reminder.description)
                reminderDetailLabel.isHidden = false
            } else {
                reminderDetailLabel.isHidden = true
            }
            if let repeatx = repeatt {
                repeatDetailLabel.configure(with: repeatx.description)
                repeatDetailLabel.isHidden = false
            } else {
                repeatDetailLabel.isHidden = true
            }
            if datee != nil || reminder != nil || repeatt != nil {
                stackView.setCustomSpacing(37, after: tokenField)
                calendarButton.tintColor = .hex("#447BFE")
            } else {
                stackView.setCustomSpacing(5, after: tokenField)
                calendarButton.tintColor = .hex("#A4A4A4")
            }
        }
    }

    var tags: [String] = [] {
        didSet {
            updateTokenField()
            tagButton.tintColor = !tags.isEmpty ? .hex("#00CE15") : .hex("#A4A4A4")
        }
    }
    var priority: Priority = .none {
        didSet {
            checkbox.configure(priority: priority)
            priorityButton.tintColor = priority != .none ? priority.color : .hex("#A4A4A4")
        }
    }
    init(onCalendarClicked: @escaping (UIView) -> Void,
         onTagClicked: @escaping (UIView) -> Void,
         onPriorityClicked: @escaping (UIView) -> Void,
         onTagPlusClicked: @escaping () -> Void,
         shouldAnimate: @escaping () -> Bool,
         shouldCreateTask: @escaping (ProjectDetailsTaskCreateModel) -> Void) {
        self.onCalendarClicked = onCalendarClicked
        self.onTagClicked = onTagClicked
        self.onPriorityClicked = onPriorityClicked
        self.onTagPlusClicked = onTagPlusClicked
        self.shouldAnimate = shouldAnimate
        self.shouldCreateTask = shouldCreateTask
        super.init(frame: .zero)
        self.priority = .medium
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }
    func setupViews() {
        backgroundColor = .hex("#ffffff")
        layer.cornerRadius = 16
        layout(checkbox).leading(26).top(22)
        layout(plusButton).trailing(20).bottom(20)
        layout(nameField).leading(checkbox.anchor.trailing, 13).centerY(checkbox.anchor.centerY).trailing(25)
        layout(taskDescription).leading(25).trailing(25).top(checkbox.anchor.bottom, 17)

        taskDescription.snp.makeConstraints { make in
            make.height.equalTo(taskDescriptionFont.lineHeight)
        }
        taskDescription.shouldSetHeight = { [unowned self] newHeight in
            self.taskDescription.snp.remakeConstraints { make in
                make.height.equalTo(min(newHeight, ceil(self.taskDescriptionFont.lineHeight) * 2 + self.taskDescriptionFont.lineHeight / 5 ))
            }

            self.shouldUpdateLayout()
        }
        
        layout(calendarButton).leading(25).bottom(18).width(25).height(25)
        layout(tagButton).leading(calendarButton.anchor.trailing, 25).bottom(18).width(25).height(25)
        layout(priorityButton).leading(tagButton.anchor.trailing, 25).bottom(18).width(25).height(25)
    }
    
    func didAppear() {
        layout(stackView).leading(25).trailing(25).bottom(plusButton.anchor.top, 10).top(taskDescription.anchor.bottom, 10)
    }
    
    func getFirstResponder() -> UIView? {
        if nameField.isFirstResponder {
            return nameField
        }
        if taskDescription.textField.isFirstResponder {
            return taskDescription.textField
        }
        return nil
    }
    
    private func resetView() {
        nameField.text = ""
        taskDescription.text = ""
        tags = []
        date = (nil, nil, nil)
        priority = .none
    }
    
    private func shouldUpdateLayout() {
        if shouldAnimate() {
            UIView.animate(withDuration: 0.5) {
                self.layoutSubviews()
                self.shouldLayoutSubviews()
            }
        } else {
        }
    }
    
    private func updateTokenField() {
        guard !tags.isEmpty else {
            tokenField.isHidden = true
            self.tokenField.removeAllTokens()
            tokenFieldSpacerBefore.isHidden = true
            return
        }
        self.tokenField.isHidden = false
        self.tokenFieldSpacerBefore.isHidden = false
        let old = tokenField.tokens as? [ResizingToken]
        let newTags = tags.map { ResizingToken(title: $0) }
        tokenField.deepdiff(old: old ?? [], new: newTags)
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tokenFieldSpacerBefore, tokenField, stackDateDetail, stackReminderRepeat])
        stackView.axis = .vertical
        stackView.setCustomSpacing(6, after: stackDateDetail)
        return stackView
    }()
    
    lazy var tokenField: ResizingTokenField = {
        let tokenField = ResizingTokenField()
        tokenField.delegate = self
        tokenField.itemSpacing = 4
        tokenField.allowDeletionTags = false
        tokenField.hideLabel(animated: false)
        tokenField.font = .systemFont(ofSize: 15, weight: .semibold)
        tokenField.preferredTextFieldReturnKeyType = .done
        tokenField.contentInsets = .zero
        tokenField.heightAnchor.constraint(lessThanOrEqualToConstant: 135).isActive = true
        tokenField.isHidden = true
        tokenField.onPlusButtonClicked = onTagPlusClicked
        
        return tokenField
    }()
    let tokenFieldSpacerBefore: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return view
    }()
    
    let checkbox: CheckboxView = {
        let checkbox = CheckboxView()
        checkbox.configure(isChecked: false)
        return checkbox
    }()
    lazy var nameField: UITextField = {
        let textField = UITextField()

        textField.delegate = self
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
    
    private var __lastCreated = Date.distantPast
    func plusClicked() {
        let lastCreatedBefore10secs = (Date() - __lastCreated).second.flatMap { $0 > 2 } ?? true
        print("lastCreated - seconds: \((Date() - __lastCreated).second) \(lastCreatedBefore10secs)")
        guard let name = nameField.text, !name.isEmpty && lastCreatedBefore10secs else { return }
        __lastCreated = Date()
        let newTask = ProjectDetailsTaskCreateModel(
            priority: priority,
            name: name,
            description: taskDescription.text,
            tags: tags,
            date: date.0,
            reminder: date.1,
            repeatt: date.2)
        shouldCreateTask(newTask)
        resetView()
    }
    
    private lazy var plusButton: CustomButton = {
        let button = CustomButton()
        button.onClick = plusClicked
        let plus = UIView()
        plus.widthAnchor.constraint(equalToConstant: 50).isActive = true
        plus.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        plus.backgroundColor = .hex("#447BFE")
        let imageView = UIImageView(image: UIImage(named: "plus"))
        plus.layout(imageView).width(18).height(18).center()
        button.layout(plus).edges()
        return button
    }()

    private let taskDescriptionFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    lazy var taskDescription: MyGrowingTextView = {
        let textView = MyGrowingTextView(placeholderText: "Need to add notes?")
        textView.growingTextFieldDelegate = self
        textView.onEnter = { }
        let attributes = Attributes().lineSpacing(5).foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 16, weight: .regular))
        textView.placeholderAttrs = attributes
        textView.textFieldAttrs = attributes

        return textView
    }()
    
    lazy var stackDateDetail: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.addArrangedSubview(dateDetailLabel)
        stack.addArrangedSubview(UIView()) // empty view
        return stack
    }()

    lazy var stackReminderRepeat: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.spacing = 6
        stack.layoutMargins = .init(top: 6, left: 0, bottom: 0, right: 0)
        stack.addArrangedSubview(reminderDetailLabel)
        stack.addArrangedSubview(repeatDetailLabel)
        stack.addArrangedSubview(UIView()) // empty view
        //stack.distribution = .fill
        return stack
    }()
    
    let dateDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "alarm")?.resize(toWidth: 14))
        view.isHidden = true
        return view
    }()

    let reminderDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "bell")?.resize(toWidth: 16))
        view.isHidden = true
        return view
    }()
    
    let repeatDetailLabel: DateDetailLabel = {
        let view = DateDetailLabel()
        view.setImage(image: UIImage(named: "repeat")?.resize(toWidth: 13))
        view.isHidden = true
        return view
    }()

}

extension ProjectNewTaskForm: ResizingTokenFieldDelegate {
    func resizingTokenField(_ tokenField: ResizingTokenField, willChangeHeight newHeight: CGFloat) {
        print("will change height")
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, didChangeHeight newHeight: CGFloat) {
        print("did change height")
        
    }
    func resizingTokenFieldShouldCollapseTokens(_ tokenField: ResizingTokenField) -> Bool {
        false
    }
    
    func resizingTokenFieldCollapsedTokensText(_ tokenField: ResizingTokenField) -> String? {
        nil
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, configurationForDefaultCellRepresenting token: ResizingTokenFieldToken) -> DefaultTokenCellConfiguration? {
        ResizingTokenConfiguration()
    }
}
extension ProjectNewTaskForm: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField: taskDescription.textField.becomeFirstResponder()
        default: break
        }
        return true
    }
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
        setScale(0.9, for: .highlighted)
    }
}
