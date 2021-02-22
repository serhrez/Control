//
//  AllTasksToolbar.swift
//  TodoApp
//
//  Created by sergey on 10.11.2020.
//

import Foundation
import UIKit
import Material
import Haptica

final class AllTasksToolbar: UIView {
    static let estimatedHeight: CGFloat = 64
    private let containerView = CustomButton(frame: .zero)
    
    var onClick: () -> Void {
        get { containerView.onClick }
        set {
            containerView.onClick = {
                Haptic.impact(.light).generate()
                newValue()
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        containerView.backgroundColor = UIColor(named: "TAAltBackground")!
        containerView.layer.cornerRadius = 32
        containerView.layer.cornerCurve = .continuous
        containerView.layer.borderWidth = 1
        layout(containerView).edges().height(Self.estimatedHeight)
        let plusView = PlusView()

        let label = UILabel()
        label.text = "To-Do., Something new?".localizable()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor(named: "TASubElement")!
        label.minimumScaleFactor = 0.87
        label.font = Fonts.heading4
        containerView.layout(plusView).trailing(7).top(7).bottom(7)
        containerView.layout(label).leading(30).trailing(plusView.anchor.leading, 10).top(20).bottom(20)

    }
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        containerView.layer.borderColor = UIColor(named: "TASpecial1")!.cgColor
    }
}
