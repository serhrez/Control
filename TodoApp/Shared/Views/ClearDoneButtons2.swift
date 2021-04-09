//
//  ClearDoneButtons2.swift
//  TodoApp
//
//  Created by sergey on 09.04.2021.
//

import Foundation
import UIKit
import Material
import AttributedLib

class ClearDoneButtons2: UIView {
    private let clear: () -> Void
    private let done: () -> Void
    let clearButton = NewCustomButton(type: .custom)
    let doneButton = NewCustomButton(type: .custom)

    init(clear: @escaping () -> Void, done: @escaping () -> Void) {
        self.clear = clear
        self.done = done
        super.init(frame: .zero)
        let attrClear = "Clear".localizable().at.attributed { attr in
            attr.font(Fonts.heading3).foreground(color: UIColor(named: "TAHeading")!)
        }
        clearButton.addTarget(self, action: #selector(clearClicked), for: .touchUpInside)
        clearButton.setAttributedTitle(attrClear, for: .normal)
        clearButton.opacityState = .opacity()
        clearButton.pointInsideInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        
        let attrDone = "Done".localizable().at.attributed { attr in
            attr.font(Fonts.heading3).foreground(color: .hex("#447BFE"))
        }
        doneButton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
        doneButton.setAttributedTitle(attrDone, for: .normal)
        doneButton.opacityState = .opacity()
        doneButton.pointInsideInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        layout(clearButton).leading(21).bottom(21).top(21)
        layout(doneButton).trailing(21).bottom(21).top(21)
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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return clearButton.hitTest(convert(point, to: clearButton), with: event) ?? doneButton.hitTest(convert(point, to: doneButton), with: event)
    }
}
