//
//  TimePickerVc.swift
//  TodoApp
//
//  Created by sergey on 28.11.2020.
//

import Foundation
import UIKit
import Material
import Typist

class TimePickerVc: UIViewController {
    private let timeSelectionHoursView: TimeSelectionxView
    private let timeSelectionMinutesView: TimeSelectionxView
    var selectedTime: (hours: Int, minutes: Int) {
        (hours: timeSelectionHoursView.selected, minutes: timeSelectionMinutesView.selected)
    }
    var manualSelectedTime: (hours: Int, minutes: Int) {
        let hours = leftNumber.text.flatMap { Int($0) } ?? 0
        let minutes = rightNumber.text.flatMap { Int($0) } ?? 0
        return (hours: hours, minutes: min(minutes, 59))
    }
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        view.layer.cornerRadius = 16
        return view
    }()
    private let incontainerCenter: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let twoDots: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 58, weight: .semibold)
        return label
    }()
    private let leftNumber: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 58, weight: .regular)
        label.adjustsFontSizeToFitWidth = false
        label.text = "00"
        label.lineBreakMode = .byClipping
        return label
    }()
    private let rightNumber: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 58, weight: .regular)
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byClipping
        label.text = "00"
        return label
    }()
    let keyboard = Typist()
    let numberField: UITextField = UITextField()
    private var clearDoneButtons: ClearDoneButtons!
    
    init(hours: Int, minutes: Int, onDone: @escaping ((hours: Int, minutes: Int)) -> Void) {
        self.timeSelectionHoursView = TimeSelectionxView(maxNumber: 24, selected: hours)
        self.timeSelectionMinutesView = TimeSelectionxView(maxNumber: 60, selected: minutes)
        
        self.leftNumber.isHidden = true
        self.rightNumber.isHidden = true
        
        super.init(nibName: nil, bundle: nil)
        clearDoneButtons = ClearDoneButtons(clear: { [weak self] in
            guard let self = self else { return }
            self.timeSelectionHoursView.beforeDisappear()
            self.timeSelectionMinutesView.beforeDisappear()
            self.navigationController?.popViewController(animated: true)
        }, done: { [weak self] in
            guard let self = self else { return }
            self.timeSelectionHoursView.beforeDisappear()
            self.timeSelectionMinutesView.beforeDisappear()
            if self.leftNumber.isHidden {
                onDone(self.selectedTime)
            } else {
                onDone(self.manualSelectedTime)
            }
            self.navigationController?.popViewController(animated: true)
        })
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        applySharedNavigationBarAppearance()
        view.backgroundColor = UIColor(named: "TABackground")
        view.addSubview(numberField)
        numberField.keyboardType = .numberPad
        numberField.becomeFirstResponder()
        numberField.delegate = self
        view.layout(containerView).leadingSafe(13).trailingSafe(13)
        containerView.layout(incontainerCenter).top(53).centerX().width(containerView.anchor.width).multiply(0.63)
        incontainerCenter.layout(timeSelectionHoursView).leading().top().bottom()
        incontainerCenter.layout(twoDots).center()
        incontainerCenter.layout(timeSelectionMinutesView).trailing().top().bottom()
        incontainerCenter.layout(rightNumber).trailing(-1).centerY().width(timeSelectionMinutesView.anchor.width)
        incontainerCenter.layout(leftNumber).leading(1).centerY().width(timeSelectionHoursView.anchor.width)
        containerView.layout(clearDoneButtons).top(incontainerCenter.anchor.bottom, 63).bottom(20).leading(20).trailing(20)
        setupKeyboard()
        self.containerView.snp.makeConstraints { make in
            make.bottom.equalTo(0)
        }
    }
    
    private func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [weak self] options in
                guard let self = self else { return }
                let height = options.endFrame.intersection(self.view.bounds).height + 15
                guard previousHeight != height && height > 40 else { return }
                previousHeight = height
                print("new height: \(height)")
                self.containerView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
            }
            .on(event: .willHide) { [weak self] options in
                guard let self = self else { return }
                let height = options.endFrame.intersection(self.view.bounds).height + 15
                guard previousHeight != height && height > 40 else { return }
                previousHeight = height
                print("new height from willHide: \(height)")
                self.containerView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
            }
            .start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        [timeSelectionHoursView, timeSelectionMinutesView].forEach { $0.viewDidAppear() }
    }
}

extension TimePickerVc: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        print(updatedText)
        guard updatedText.allSatisfy({ $0.isNumber }) || updatedText.isEmpty else { return false }
        timeSelectionHoursView.isHidden = updatedText.count != 0
        timeSelectionMinutesView.isHidden = updatedText.count != 0
        leftNumber.isHidden = updatedText.count == 0
        rightNumber.isHidden = updatedText.count == 0
        if !updatedText.isEmpty {
            let validated = validate(text: updatedText)
            textField.text = validated
            if validated.count == 1 {
                leftNumber.text = "00"
                rightNumber.text = "0\(validated)"
            }
            if validated.count == 2 {
                leftNumber.text = "00"
                rightNumber.text = "\(validated)"
            }
            if validated.count == 3 {
                leftNumber.text = "0\(validated.dropLast(2))"
                rightNumber.text = "\(validated.dropFirst())"
            }
            if validated.count == 4 {
                leftNumber.text = "\(validated.dropLast(2))"
                rightNumber.text = "\(validated.dropFirst(2))"
            }
            return false
        }
        return true
    }
    
    func validate(text textP: String) -> String {
        let shouldDrop = max(textP.count - 4, 0)
        let text = textP.dropFirst(shouldDrop)
        if text.count == 4 {
            let hours = Int(text.dropLast(2))!
            if hours >= 23 {
                return String(text.dropFirst())
            }
        }
        return String(text)
    }
}
