//
//  TextFieldCell.swift
//  ResizingTokenField
//
//  Created by Tadej Razborsek on 19/06/2019.
//  Copyright © 2019 Tadej Razborsek. All rights reserved.
//

import UIKit

private class DeleteDetectingTextField: UITextField {
    var onDeleteBackwardWhenEmpty: (() -> ())?
    
    override public func deleteBackward() {
        let isEmpty: Bool = text?.isEmpty ?? false
        super.deleteBackward()
        
        if isEmpty {
            onDeleteBackwardWhenEmpty?()
        }
    }
}

class TextFieldCell: UICollectionViewCell {
    
    /// Implement to handle text field changes.
    var onTextFieldEditingChanged: ((String?) -> Void)?
    
    /// Implement to handle delete backward when empty.
    var onDeleteBackwardWhenEmpty: (() -> ())?
    
    let textField: UITextField = DeleteDetectingTextField(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    let greenBgLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 0.1).cgColor
        layer.cornerRadius = 11
        layer.cornerCurve = .continuous
        return layer
    }()
    override var bounds: CGRect {
        didSet {
            greenBgLayer.frame = bounds
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    private func setUp() {
        layer.addSublayer(greenBgLayer)
        addSubview(textField)
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1)
        textField.font = .systemFont(ofSize: 15, weight: .semibold)
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        (textField as? DeleteDetectingTextField)?.onDeleteBackwardWhenEmpty = { [weak self] in
            self?.onDeleteBackwardWhenEmpty?()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    // MARK: - Handling text field changes
    
    @objc func textFieldEditingChanged(textField: UITextField) {
        if textField == self.textField {
            onTextFieldEditingChanged?(textField.text)
        }
    }
    
}
