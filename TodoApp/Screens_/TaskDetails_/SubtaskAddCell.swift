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
        contentView.layout(plusImage).centerY().leading().width(18).height(18)
        contentView.layout(textField).centerY().leading(31).trailing(10)
        textField.delegate = self
        selectionStyle = .none
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
}
