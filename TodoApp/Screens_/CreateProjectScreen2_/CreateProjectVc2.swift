//
//  CreateProjectVc2.swift
//  TodoApp
//
//  Created by sergey on 20.12.2020.
//

import Foundation
import UIKit
import Material
import SnapKit
import AttributedLib
import Typist

class CreateProjectVc2: UIViewController {
    let keyboard = Typist()
    var icon: Icon = .text("🚒")
    var color: UIColor =  .hex("#FF9900")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboard()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        projectNameField.becomeFirstResponder()
    }
    
    private func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                previousHeight = height
                print("new height: \(height)")
                containerView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-(max(height, view.safeAreaInsets.bottom)))
                }
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                previousHeight = height
                print("new height from willHide: \(height)")
                containerView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-(max(height, view.safeAreaInsets.bottom)))
                }
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .start()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print("keyboardheight: \(keyboardHeight)")
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print("keyboardheight: \(keyboardHeight)")
        }
    }

    
    private func setupViews() {
        view.backgroundColor = .hex("#F6F6F3")
        view.layout(containerView).leading().trailing()
        containerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        containerView.layout(plusButton).bottom(20).trailing(20)
        containerView.layout(closeButton).top(12).trailing(12)
        containerView.layout(colorCircle).top(42).leading(26)
        containerView.layout(projectNameField).leading(colorCircle.anchor.trailing, 13).centerY(colorCircle.anchor.centerY).trailing(36)
        containerView.layout(projectDescription).top(projectNameField.anchor.bottom, 5).leading(projectNameField.anchor.leading).bottom(plusButton.anchor.top, 38).trailing(36)
        view.layout(clickableIcon).top(containerView.anchor.top, -24).leading(26)
        
        let heightConstraint = self.projectDescription.heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.isActive = true
        projectDescription.shouldSetHeight = { [weak self] in
            heightConstraint.constant = $0
            UIView.animate(withDuration: 0.5) {
                self?.containerView.layoutSubviews()
                self?.view.layoutSubviews()
            }
        }

    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    private func plusClicked() {
        let allProject = RealmProvider.main.realm.objects(RlmProject.self)
        guard let projectName = projectNameField.text,
              !projectName.isEmpty,
              !allProject.contains(where: { $0.name == projectName }) else { return }
        let description = projectDescription.text
        let project = RlmProject(name: projectName, icon: icon, notes: description, color: color, date: Date())
        _ = try! RealmProvider.main.realm.write {
            RealmProvider.main.realm.add(project)
        }
        router.navigationController.popViewController(animated: true)
    }
    private func closeClicked() {
        router.navigationController.popViewController(animated: true)
    }
    
    private func colorSelection() {
        
        let colorPicker = ColorPicker(viewSource: colorCircle, selectedColor: color, onColorSelection: { [weak self] newColor, picker in
            self?.color = newColor
            self?.colorCircle.circleColor = newColor
        })
        
        colorPicker.shouldPurposelyAnimateViewBackgroundColor = true
        addChildPresent(colorPicker)
        
        colorPicker.shouldDismiss = { [weak colorPicker] in
            colorPicker?.addChildDismiss()
        }
    }

    private lazy var colorCircle: GappedCircle = {
        let circle = GappedCircle(circleColor: color, widthHeight: 22)
        circle.onClick = self.colorSelection
        circle.configure(isSelected: true, animated: false)
        return circle
    }()

    private lazy var closeButton = CloseButton(onClicked: closeClicked)
    
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
    
    lazy var projectDescription: MyGrowingTextView = {
        let description = MyGrowingTextView(placeholderText: "Notes")
        description.onEnter = { }
        let attributes: Attributes = Attributes().lineSpacing(5).foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 20, weight: .regular))
        description.placeholderAttrs = attributes
        description.textFieldAttrs = attributes
        description.growingTextFieldDelegate = self
        return description
    }()
        
    private func iconSelected() {
        print("iconSelected")
        //        guard let project = viewModel.project else { return }
//        let iconPicker = IconPicker(viewSource: clickableIcon, selected: project.icon, onSelection: viewModel.setProjectIcon)
//        present(iconPicker, animated: true, completion: nil)
    }

    
    private lazy var projectNameField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 28, weight: .bold)
        textField.textColor = .hex("#242424")
        textField.delegate = self
        textField.attributedPlaceholder = "New Project".at.attributed { attr in
            attr.foreground(color: .hex("#A4A4A4")).font(.systemFont(ofSize: 28, weight: .bold))
        }
        return textField
    }()
    private lazy var clickableIcon: ClickableIconView = {
        let iconView = ClickableIconView(onClick: iconSelected)
        iconView.iconView.iconFontSize = 48
        iconView.iconView.configure(icon)
        iconView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return iconView
    }()

    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension CreateProjectVc2: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case projectNameField:
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            return updatedText.count < Configgg.maximumProjectNameLength
        default: break
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case projectNameField:
            projectDescription.textField.becomeFirstResponder()
        default: break
        }
        return true
    }
}

extension CreateProjectVc2: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch textView {
        case projectDescription.textField :
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

            return updatedText.count < Configgg.maximumDescriptionLength
        default: break
        }
        return true
    }
    
}

extension CreateProjectVc2: AppNavigationRouterDelegate { }
