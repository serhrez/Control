//
//  CreateProjectVc.swift
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
import Haptica

class CreateProjectVc: UIViewController {
    let keyboard = Typist()
    var icon: Icon = .text(getRandomEmoji()) {
        didSet {
            self.clickableIcon.iconView.configure(icon)
        }
    }
    var color: UIColor = Constants.colorsForRandom.randomElement()!
    private var didAppear: Bool = false
    private var shouldChangeHeightByKeyboardChange = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboard()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        projectNameField.becomeFirstResponder()
        didAppear = true
    }
    
    private func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [weak self] options in
                guard let self = self else { return }
                guard self.shouldChangeHeightByKeyboardChange else { return }
                let height = options.endFrame.intersection(self.view.bounds).height
                guard previousHeight != height else { return }
                previousHeight = height
                print("new height: \(height)")
                self.containerView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-(max(height, self.view.safeAreaInsets.bottom)))
                }
                UIView.animate(withDuration: Constants.animationDefaultDuration) {
                    self.view.layoutSubviews()
                }
            }
            .on(event: .willHide) { [weak self] options in
                guard let self = self else { return }
                guard self.shouldChangeHeightByKeyboardChange else { return }
                let height = options.endFrame.intersection(self.view.bounds).height
                guard previousHeight != height else { return }
                previousHeight = height
                print("new height from willHide: \(height)")
                self.containerView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-(max(height, self.view.safeAreaInsets.bottom)))
                }
                UIView.animate(withDuration: Constants.animationDefaultDuration) {
                    self.view.layoutSubviews()
                }
            }
            .start()
    }
    
    private func setupViews() {
        applySharedNavigationBarAppearance()
        view.backgroundColor = UIColor(named: "TABackground")
        view.layout(containerView).leading().trailing()
        containerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        containerView.layout(plusButton).bottom(20).trailing(20)
        containerView.layout(closeButton).top(12).trailing(12)
        containerView.layout(colorCircle).top(42).leading(26)
        containerView.layout(projectNameField).leading(colorCircle.anchor.trailing, 13).centerY(colorCircle.anchor.centerY).trailing(36).bottom(plusButton.anchor.top, 38)
        view.layout(clickableIcon).top(containerView.anchor.top, -24).leading(26)
    }
    
    func properlyLayout() {
        func apply() {
            self.containerView.layoutSubviews()
            self.view.layoutSubviews()
        }
        if didAppear {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                apply()
            }
        } else {
            apply()
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private func plusClicked() {
        let allProject = RealmProvider.main.realm.objects(RlmProject.self)
        guard let projectName = projectNameField.text,
              !projectName.isEmpty,
              !allProject.contains(where: { $0.name == projectName }) else {
            Haptic.impact(.light).generate()
            AnimationsFactory.jiggleWithMove(plusButton).startAnimation()
            return
        }
        let project = RlmProject(name: projectName, icon: icon, notes: "", color: color, date: Date())
        RealmProvider.main.safeWrite {
            RealmProvider.main.realm.add(project)
        }
        shouldChangeHeightByKeyboardChange = false
        router.openProjectDetails(project: project, state: .new, shouldPopTwo: true)
    }
    private func closeClicked() {
        router.navigationController.popViewController(animated: true)
    }
    
    private func colorSelection() {
        
        let colorPicker = ColorPicker(viewSource: colorCircle, selectedColor: color, onColorSelection: { [weak self] newColor, picker in
            self?.color = newColor
            self?.colorCircle.circleColor = newColor
            picker.shouldDismissAnimated()
        })
        
        colorPicker.shouldPurposelyAnimateViewBackgroundColor = true
        addChildPresent(colorPicker)
        
        colorPicker.shouldDismiss = { [weak colorPicker] in
            colorPicker?.addChildDismiss()
        }
    }

    private lazy var colorCircle: GappedCircle = {
        let circle = GappedCircle(circleColor: color, widthHeight: 22)
        circle.onClick = { [weak self] in
            self?.colorSelection()
        }
        circle.configure(isSelected: true, animated: false)
        return circle
    }()

    private lazy var closeButton = CloseButton(onClicked: { [weak self] in
        self?.closeClicked()
    })
    
    private lazy var plusButton: CustomButton = {
        let button = CustomButton()
        button.onClick = { [weak self] in
            self?.plusClicked()
        }
        let plus = PlusView()
        button.layer.cornerRadius = 25
        button.layout(plus).edges()
        return button
    }()
        
    private func iconSelected() {
        shouldChangeHeightByKeyboardChange = false
        router.openIconPicker { [weak self] newIcon in
            self?.icon = .text(newIcon)
            self?.shouldChangeHeightByKeyboardChange = true
        }
    }

    private lazy var projectNameField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.heading1
        textField.textColor = UIColor(named: "TAHeading")!
        textField.delegate = self
        textField.attributedPlaceholder = "New Project".localizable().at.attributed { attr in
            attr.foreground(color: UIColor(named: "TASubElement")!).font(Fonts.heading1)
        }
        return textField
    }()
    private lazy var clickableIcon: ClickableIconView = {
        let iconView = ClickableIconView(onClick: { [weak self] in
            self?.iconSelected()
        })
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

extension CreateProjectVc: UITextFieldDelegate {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension CreateProjectVc: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
}
