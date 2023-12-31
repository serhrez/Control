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
    var pointInsideInsets: UIEdgeInsets?

    init(onClick: @escaping (Bool) -> Void) {
        self.onClick = onClick
        super.init(frame: .zero)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside])
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func touchUp() {
        onClick(true)
    }
    @objc private func touchDown() {
        onClick(false)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let customInsets = pointInsideInsets else {
            return super.point(inside: point, with: event)
        }
        if layer.opacity == 0 || isHidden {
            return false
        }
        return self.bounds.inset(by: customInsets.inverted()).contains(point)
    }
}
