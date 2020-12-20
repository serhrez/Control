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

final class SubtaskAddCell: UICollectionViewCell {
    static let reuseIdentifier = "subtaskaddcell"
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = "New Checklist...".at.attributed { attr in
            attr.font(.systemFont(ofSize: 16, weight: .regular)).foreground(color: .hex("#A4A4A4"))
        }
        return textField
    }()
    private let plusImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plus"))
        return imageView
    }()
    
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 44)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
