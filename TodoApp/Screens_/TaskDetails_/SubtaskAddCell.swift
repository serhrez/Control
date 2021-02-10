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
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = "New Checklist...".at.attributed { attr in
            attr.font(.systemFont(ofSize: 16, weight: .regular)).foreground(color: UIColor(named: "TASubElement")!)
        }
        textField.textColor = UIColor(named: "TAHeading")!
        return textField
    }()
    private let plusImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plus"))
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
        backgroundColor = UIColor(named: "TAAltBackground")!
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension SubtaskAddCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty ?? true { textField.resignFirstResponder(); return true }
        subtaskCreated?(textField.text ?? "")
        textField.text = ""
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count < Constants.subtaskLengthRestriction
    }
}
