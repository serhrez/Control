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
    
    let nameField = UITextField()
    
    var tagCreated: ((String) -> Void)?
    var shouldClose: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(tagCreated: ((String) -> Void)?, shouldClose: @escaping () -> Void) {
        self.tagCreated = tagCreated
        self.shouldClose = shouldClose
        nameField.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // TODO: remove this awful crutch
            self.nameField.becomeFirstResponder()
        }
    }

    func setupViews() {
        backgroundColor = UIColor(named: "TAAltBackground")!
        layer.cornerRadius = 16
        clipsToBounds = true
        nameField.attributedPlaceholder = "New Tag".localizable().at.attributed { attr in
            attr.foreground(color: UIColor(named: "TASubElement")!)
                .font(Fonts.heading4)
        }
        nameField.textColor = UIColor(named: "TAHeading")
        nameField.font = Fonts.heading4
        contentView.layout(nameField).centerY().leading(20).trailing(20)
        nameField.delegate = self
    }
    override func becomeFirstResponder() -> Bool {
        return nameField.becomeFirstResponder()
    }
}

extension AllTagsEnterNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        defer { textField.resignFirstResponder() }
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            shouldClose?()
            return true
        }
        tagCreated?(text)

        return true
    }
}
