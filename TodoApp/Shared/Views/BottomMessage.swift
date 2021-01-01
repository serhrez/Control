//
//  BottomMessage.swift
//  TodoApp
//
//  Created by sergey on 31.12.2020.
//

import Foundation
import UIKit
import Material

class BottomMessage: UIView {
    init(backgroundColor: UIColor, imageName: String?, text: String, textColor: UIColor, onClicked: @escaping () -> Void) {
        super.init(frame: .init(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: UIScreen.main.bounds.width - 13 * 2, height: 55))
        
        self.layer.cornerRadius = 16
        self.layer.cornerCurve = .continuous
        self.backgroundColor = backgroundColor
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        if let imageName = imageName {
            stack.addArrangedSubview(UIImageView(image: UIImage(named: imageName)))
        }
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = textColor
        stack.addArrangedSubview(label)
        layout(stack).center()
        heightAnchor.constraint(equalToConstant: 55).isActive = true
        let onClickControl = OnClickControl { isClicked in
            if isClicked { onClicked() }
        }
        layout(onClickControl).edges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BottomMessage {
    static func mm(messageType: MessageType, onClicked: @escaping () -> Void) -> BottomMessage {
        switch messageType {
        case .todosDeleted:
            return BottomMessage(backgroundColor: .red, imageName: nil, text: "fwefqwg", textColor: .green, onClicked: { })
//            self.init(backgroundColor: UIColor, imageName: String?, text: String, textColor: UIColor, onClicked: () -> Void)
        }
    }
    
    enum MessageType {
        case todosDeleted
    }
}
