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
    private static var previousBottomMessage: BottomMessage?
    init(backgroundColor: UIColor, imageName: String?, text: String, textColor: UIColor, imageColor: UIColor? = nil, imageWidth: CGFloat, onClicked: @escaping () -> Void) {
        super.init(frame: .init(x: 13, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 13 * 2, height: 55))
        
        self.layer.cornerRadius = 16
        self.layer.cornerCurve = .continuous
        self.backgroundColor = backgroundColor
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        if let imageName = imageName {
            let imageView = UIImageView(image: UIImage(named: imageName)?.resize(toWidth: imageWidth)?.withRenderingMode(.alwaysTemplate))
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = imageColor ?? textColor
            stack.addArrangedSubview(imageView)
        }
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = textColor
        stack.addArrangedSubview(label)
        layout(stack).center()
        let onClickControl = OnClickControl { [weak self] isClicked in
            if isClicked {
                onClicked()
                self?.dismiss()
            }
        }
        
        layout(onClickControl).edges()
        
    }
    var previousHeight: CGFloat?
    func show(_ points: CGFloat) {
        guard previousHeight == nil else { return }
        BottomMessage.previousBottomMessage?.dismiss()
        BottomMessage.previousBottomMessage = self
        previousHeight = self.frame.minY
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0) {
            self.frame = self.frame.modify(modifyY: { $0 - points - self.frame.height })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.dismiss()
        }
    }
    var __isDismissing = false
    func dismiss() {
        guard let previousHeight = previousHeight,
              !__isDismissing else { return }
        __isDismissing = true
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.65, initialSpringVelocity: 0) {
            self.frame = self.frame.modify(modifyY: { _ in previousHeight })
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BottomMessage {
    static func create(messageType: MessageType, onClicked: @escaping () -> Void) -> BottomMessage {
        switch messageType {
        case .taskDeleted:
            return BottomMessage(backgroundColor: .hex("#447BFE"), imageName: "arrow-back-up", text: "To-Do is Deleted, Restore?", textColor: UIColor(named: "TAAltBackground")!, imageWidth: 17, onClicked: onClicked)
        case .taskRestored:
            return BottomMessage(backgroundColor: .hex("#EF4439"), imageName: "trash", text: "To-Do is Restored, Delete?", textColor: UIColor(named: "TAAltBackground")!, imageWidth: 17, onClicked: onClicked)
        }
    }
    
    enum MessageType {
        case taskDeleted
        case taskRestored
    }
}
