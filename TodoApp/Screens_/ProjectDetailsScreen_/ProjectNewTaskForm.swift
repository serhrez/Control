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
                calendarButton.tintColor = .hex("#447BFE")
            } else {
                calendarButton.tintColor = UIColor(named: "TASubElement")!
            }
        }
    }

    var tags: [String] = [] {
        didSet {
            updateTokenField()
            tagButton.tintColor = !tags.isEmpty ? .hex("#00CE15") : UIColor(named: "TASubElement")!
        }
    }
    var priority: Priority = .none {
        didSet {
            checkbox.configure(priority: priority)
            priorityButton.tintColor = priority != .none ? priority.color : UIColor(named: "TASubElement")!
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
        addShadow(offset: .init(width: 0, height: 2), opacity: 1, radius: 16, color: UIColor(red: 0.141, green: 0.141, blue: 0.141, alpha: 0.1))
        backgroundColor = UIColor(named: "TAAltBackground")!
        layer.cornerRadius = 16
        let scrollView = UIScrollView()
        layout(scrollView).edges()
        scrollView.layout(containerView).top().leading().trailing()
        scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true // 54 bottom
        let containerHeight = heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        containerHeight.priority = .init(749)
        containerHeight.isActive = true
        scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true

        containerView.layout(checkbox).leading(26).top(22)
        containerView.layout(nameField).leading(checkbox.anchor.trailing, 13).centerY(checkbox.anchor.centerY).trailing(25)
        containerView.layout(taskDescription).leading(25).trailing(25).top(checkbox.anchor.bottom, 17)

        taskDescription.snp.makeConstraints { make in
            make.height.equalTo(taskDescriptionFont.lineHeight)
        }
        taskDescription.shouldSetHeight = { [unowned self] newHeight in
            self.taskDescription.snp.remakeConstraints { make in
                make.height.equalTo(newHeight)
            }

            self.shouldUpdateLayout()
        }
        layout(bottomView).bottom().trailing().leading().height(54)
        bottomView.layout(calendarButton).leading(25).centerY().width(25).height(25)
        bottomView.layout(tagButton).leading(calendarButton.anchor.trailing, 25).centerY().width(25).height(25)
        bottomView.layout(priorityButton).leading(tagButton.anchor.trailing, 25).centerY().width(25).height(25)
        
        layout(plusButton).trailing(20).bottom(20)
    }
    
    func didAppear() {
        containerView.layout(stackView).leading(25).trailing(25).bottom(72).top(taskDescription.anchor.bottom, 10)
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
        taskDescription.snp.remakeConstraints { make in
            make.height.equalTo(taskDescriptionFont.lineHeight)
        }
    }
    
    private func shouldUpdateLayout() {
        if shouldAnimate() {
            UIView.animate(withDuration: 0.5) {
                self.stackView.layoutSubviews()
                self.containerView.layoutSubviews()
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
            return
        }
        self.tokenField.isHidden = false
        let old = tokenField.tokens as? [ResizingToken]
        let newTags = tags.map { ResizingToken(title: $0) }
        tokenField.deepdiff(old: old ?? [], new: newTags)
    }
    
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        return view
    }()
    
    let containerView = UIView()
    
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
        tokenField.heightConstraint?.isActive = false
        tokenField.isHidden = true
        tokenField.onPlusButtonClicked = onTagPlusClicked
        tokenField.snp.makeConstraints { make in
            make.height.equalTo(tokenField.itemHeight)
        }
        
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
        textField.textColor = UIColor(named: "TAHeading")!
        let attributes = Attributes().font(UIFont.systemFont(ofSize: 20, weight: .medium))
        textField.attributedPlaceholder = "Call to John Wick?".at.attributed(with: attributes.foreground(color: UIColor(named: "TASubElement")!))
        return textField
    }()
    lazy var calendarButton: ImageButton = {
        let simpleButton = ImageButton(type: .custom)
        simpleButton.imageName = "calendar-plus"
        simpleButton.imageWidth = 16
        simpleButton.configureImage()
        simpleButton.tintColor = UIColor(named: "TASubElement")!
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
        simpleButton.tintColor = UIColor(named: "TASubElement")!
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
        simpleButton.tintColor = UIColor(named: "TASubElement")!
        simpleButton.addTarget(self, action: #selector(priorityClicked), for: .touchUpInside)
        return simpleButton
    }()
    @objc func priorityClicked() {
        onPriorityClicked(priorityButton)
    }
    
    func plusClicked() {
        guard let name = nameField.text, !name.isEmpty else { return }
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
        button.layout(PlusView()).edges()
        button.layer.cornerRadius = 25
        return button
    }()

    private let taskDescriptionFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    lazy var taskDescription: MyGrowingTextView = {
        let textView = MyGrowingTextView(placeholderText: "Need to add notes?", scrollBehavior: .noScroll)
        textView.growingTextFieldDelegate = self
        textView.onEnter = { }
        let attributes = Attributes().lineSpacing(5).foreground(color: UIColor(named: "TASubElement")!).font(.systemFont(ofSize: 16, weight: .regular))
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
    func resizingTokenField(_ tokenField: ResizingTokenField, didChangeHeight newHeight: CGFloat) {
        let extraSpace = tokenField.itemHeight * 1.5
        tokenField.snp.remakeConstraints { make in
            make.height.equalTo(newHeight + extraSpace)
        }
        self.shouldUpdateLayout()
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
