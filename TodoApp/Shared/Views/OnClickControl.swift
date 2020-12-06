//
//  OnClickControl.swift
//  TodoApp
//
//  Created by sergey on 26.11.2020.
//

import Foundation
import UIKit


class OnClickControl: UIControl {
    var onClick: (Bool) -> Void
    init(onClick: @escaping (Bool) -> Void) {
        self.onClick = onClick
        super.init(frame: .zero)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func touchUp() {
        onClick(false)
    }
    @objc private func touchDown() {
        onClick(true)
    }
}
