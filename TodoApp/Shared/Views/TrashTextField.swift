//
//  TrashTextField.swift
//  TodoApp
//
//  Created by sergey on 24.12.2020.
//

import Foundation
import UIKit

class TrashTextField: UITextField {
    init() {
        super.init(frame: .init(x: -99, y: 20, width: 101, height: 10))
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TrashTextField: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool { false }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { false }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool { true }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool { true }
}
