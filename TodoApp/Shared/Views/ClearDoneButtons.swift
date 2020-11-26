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
        let clearButton = UIButton(type: .custom)
        let attrClear = "Back".at.attributed { attr in
            attr.font(.systemFont(ofSize: 18, weight: .semibold))
        }
        clearButton.addTarget(self, action: #selector(clearClicked), for: .touchUpInside)
        clearButton.setAttributedTitle(attrClear, for: .normal)
        let separator = UIView()
        separator.backgroundColor = .hex("#DFDFDF")
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let doneButton = UIButton(type: .custom)
        let attrDone = "Done".at.attributed { attr in
            attr.font(.systemFont(ofSize: 18, weight: .semibold)).foreground(color: .hex("#447BFE"))
        }
        doneButton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
        doneButton.setAttributedTitle(attrDone, for: .normal)
        let container1 = UIView()
        container1.layout(clearButton).center()
        let container2 = UIView()
        container2.layout(doneButton).center()
        [container1, separator, container2].forEach { addSubview($0) }
        layout(container1).width(container2.anchor.width).top().bottom().leading().trailing(separator.anchor.leading, 6)
        layout(separator).top().bottom().trailing(container2.anchor.leading, 6)
        layout(container2).top().bottom().trailing()

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
