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
    var growingTextFieldDelegate: UITextViewDelegate?
    let placeholderLabel = UILabel()
    private let placeholderText: String
    var onEnter: (() -> Void)?
    var placeholderVisible: Bool = true {
        didSet {
            placeholderLabel.isHidden = !placeholderVisible
        }
    }
    var placeholderAttrs: Attributes {
        set {
            placeholderLabel.attributedText = placeholderText.at.attributed(with: newValue)
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
    init(placeholderText: String) {
        self.placeholderText = placeholderText
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
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard growingTextFieldDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true else { return false }
        if text == "\n" {
            if onEnter != nil {
                onEnter?()
            } else {
                textView.resignFirstResponder()
            }
            return false
        }
        return true
    }
}
