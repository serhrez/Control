//
//  OvalText.swift
//  TodoApp
//
//  Created by sergey on 16.11.2020.
//

import Foundation
import UIKit
import Material

class OvalText: UIView {
    var bgColor: UIColor? {
        didSet {
            containerView.backgroundColor = bgColor
        }
    }
    var text: String? {
        set {
            guard let text = newValue else { return }
            label.text = text
        }
        get { label.text }
    }
    
    private let containerView = UIView()
    private let height: CGFloat
    private var label: UILabel!

    init(height: CGFloat = 26) {
        self.height = height
        super.init(frame: .zero)
        backgroundColor = .clear
        label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .bold)
        containerView.backgroundColor = bgColor
        layout(containerView).edges().height(height)
        containerView.layout(label).centerY().leading(7).trailing(7)
        containerView.layer.cornerRadius = 13
        containerView.layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
