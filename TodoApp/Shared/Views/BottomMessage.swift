//
//  BottomMessage.swift
//  TodoApp
//
//  Created by sergey on 31.12.2020.
//

import Foundation
import UIKit
import Material
import Haptica

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
            imageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = imageColor ?? textColor
            stack.addArrangedSubview(imageView)
        }
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = textColor
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        stack.addArrangedSubview(label)
        layout(stack).center().leading(20) { _, _ in .greaterThanOrEqual }.trailing(20) { _, _ in .lessThanOrEqual }
        let onClickControl = OnClickControl { [weak self] isClicked in
            if isClicked {
                Haptic.impact(.light).generate()
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
        UIView.animate(withDuration: Constants.animationBottomMessagesDuration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
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
        UIView.animate(withDuration: Constants.animationBottomMessagesDuration, delay: 0.1, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
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
            return BottomMessage(backgroundColor: .hex("#447BFE"), imageName: "arrow-back-up", text: "To-Do is Moved to Archive, Restore?", textColor: UIColor(named: "TAAltBackground")!, imageWidth: 17, onClicked: onClicked)
        case .allTasksDeleted:
            return BottomMessage(backgroundColor: .hex("#EF4439"), imageName: "trash", text: "To-Dos Moved to Archive, Restore?", textColor: UIColor(named: "TAAltBackground")!, imageWidth: 17, onClicked: onClicked)
        case .taskCreatedInInbox:
            return BottomMessage(backgroundColor: .hex("#FFE600"), imageName: nil, text: "New Task Has Been Created in Inbox", textColor: UIColor(named: "TAHeading")!, imageWidth: 17, onClicked: onClicked)
        }
    }
    
    enum MessageType {
        case taskDeleted
        case allTasksDeleted
        case taskCreatedInInbox
    }
}
