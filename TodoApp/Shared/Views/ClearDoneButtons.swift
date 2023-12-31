//
//  ClearDoneButtons.swift
//  TodoApp
//
//  Created by sergey on 26.11.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

class ClearDoneButtons: UIView {
    private let clear: () -> Void
    private let done: () -> Void
    init(clear: @escaping () -> Void, done: @escaping () -> Void) {
        self.clear = clear
        self.done = done
        super.init(frame: .zero)
        let clearButton = NewCustomButton(type: .custom)
        let attrClear = "Back".localizable().at.attributed { attr in
            attr.font(Fonts.heading3)
        }
        clearButton.addTarget(self, action: #selector(clearClicked), for: .touchUpInside)
        clearButton.setAttributedTitle(attrClear, for: .normal)
        clearButton.opacityState = .opacity()
        
        let separator = UIView()
        separator.backgroundColor = UIColor(named: "TABorder")!
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let doneButton = NewCustomButton(type: .custom)
        let attrDone = "Done".localizable().at.attributed { attr in
            attr.font(Fonts.heading3).foreground(color: .hex("#447BFE"))
        }
        doneButton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
        doneButton.setAttributedTitle(attrDone, for: .normal)
        doneButton.opacityState = .opacity()
        
        layout(clearButton).leading().bottom().top()
        layout(separator).top().bottom().leading(clearButton.anchor.trailing)
        layout(doneButton).top().bottom().leading(separator.anchor.trailing).trailing()
        clearButton.widthAnchor.constraint(equalTo: doneButton.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doneClicked() {
        done()
    }
    
    @objc func clearClicked() {
        clear()
    }
}
