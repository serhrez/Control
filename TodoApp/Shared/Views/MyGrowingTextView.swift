//
//  MyGrowingTextView.swift
//  TodoApp
//
//  Created by sergey on 19.12.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

class MyGrowingTextView: UIView, UITextViewDelegate {
    let textField = UITextView()
//    lazy var heightConstraint: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: 40)
    let placeholderLabel = UILabel()
    var placeholderVisible: Bool = true {
        didSet {
//            heightConstraint.isActive = !placeholderVisible
            placeholderLabel.isHidden = !placeholderVisible
        }
    }
    var placeholderAttrs: Attributes {
        set {
            placeholderLabel.attributedText = "Enter description".at.attributed(with: newValue)
        }
        get { Attributes() }
    }
    var textFieldAttrs: Attributes {
        set {
            textField.attributedText = " ".at.attributed(with: newValue)
            textField.text = ""
        }
        get { Attributes() }
    }
    init() {
        super.init(frame: .zero)
        layout(placeholderLabel).centerY().leading().trailing()
        layout(textField).edges()
        
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.textContainerInset = .zero
        textField.contentInset = .zero
        textField.textContainer.lineFragmentPadding = 0
        textField.isScrollEnabled = false
        placeholderVisible = true        
    }
    var wasLayouted: Bool = false
    
    override func layoutSubviews() {
        if !wasLayouted {
            textViewDidChange(textField)
            wasLayouted = true
        }
        super.layoutSubviews()
    }
    
    var text: String {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var shouldSetHeight: (CGFloat) -> Void = { _ in }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderVisible = textView.text.isEmpty
        let size = CGSize(width: bounds.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        shouldSetHeight(estimatedSize.height)
//        heightConstraint.constant = estimatedSize.height
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
