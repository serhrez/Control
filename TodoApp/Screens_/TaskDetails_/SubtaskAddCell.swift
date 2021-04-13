//
//  SubtaskAddCell.swift
//  TodoApp
//
//  Created by sergey on 19.11.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

final class SubtaskAddCell: UITableViewCell {
    static let reuseIdentifier = "subtaskaddcell"
    static let height: CGFloat = 44

    private let textField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = "New Checklist...".localizable().at.attributed { attr in
            attr.font(Fonts.text).foreground(color: UIColor(named: "TASubElement")!)
        }
        textField.textColor = UIColor(named: "TAHeading")!
        return textField
    }()
    private let plusImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plus")?.withTintColor(UIColor(named: "TABorder")!))
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var subtaskCreated: ((String) -> Void)?
    
    func setupViews() {
        contentView.layout(plusImage).centerY().leading(2).width(18).height(18)
        contentView.layout(textField).centerY().leading(31).trailing(10)
        contentView.backgroundColor = .clear
        textField.delegate = self
        selectionStyle = .none
        backgroundColor = UIColor(named: "TABackground")!
        textField.inputAccessoryView = AccessoryView(onDone: { [weak self] in
            guard let self = self else { return }
            self.addSubtask()
        }, onHide: { [weak textField] in
            textField?.endEditing(true)
        })
    }
    
    private func addSubtask() {
        if textField.text?.isEmpty ?? true {
            textField.resignFirstResponder()
            return
        }
        subtaskCreated?(textField.text ?? "")
        textField.text = ""

    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension SubtaskAddCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty ?? true {
            textField.resignFirstResponder()
            return true
        }
        addSubtask()
        return false
    }
    
}
