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

class AllTagsEnterNameCell: UICollectionViewCell {
    static let reuseIdentifier = "alltagsenternamecell"
    
    private let nameField = UITextField()
    
    var tagCreated: ((String) -> Void)?
    
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 55)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(tagCreated: ((String) -> Void)?) {
        self.tagCreated = tagCreated
        nameField.text = ""
    }

    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        nameField.attributedPlaceholder = "New Tag".at.attributed { attr in
            attr.foreground(color: .hex("#A4A4A4"))
                .font(.systemFont(ofSize: 16, weight: .semibold))
        }
        nameField.textColor = .black
        nameField.font = .systemFont(ofSize: 16, weight: .semibold)
        layout(nameField).centerY().leading(20).trailing(20)
        nameField.delegate = self
    }
}

extension AllTagsEnterNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tagCreated?(textField.text ?? "")
        return true
    }
}
