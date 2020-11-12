//
//  AllTagsEnterNameCEll.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

class AllTagsEnterNameCell: UIView {
    static let reuseIdentifier = "alltagsenternamecell"
    
    var tagCreated: ((String) -> Void)?
    
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 55)
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    func configure(tagCreated: ((String) -> Void)?) {
        self.tagCreated = tagCreated
        setupViews()
    }

    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        let nameField = UITextField()
        nameField.attributedPlaceholder = "New Tag".at.attributed { attr in
            attr.foreground(color: .hex("#A4A4A4"))
                .font(.systemFont(ofSize: 16, weight: .semibold))
        }
        nameField.textColor = .black
        layout(nameField).centerY().leading(20).trailing(20)
        nameField.delegate = self
//        nameField.attributedPlaceholder
    }
}

extension AllTagsEnterNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        textField.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            textField.isEnabled = true
            textField.text = ""
        }
        tagCreated?(textField.text ?? "")
        return true
    }
}
