//
//  DateDetailLabel.swift
//  TodoApp
//
//  Created by sergey on 21.11.2020.
//

import Foundation
import UIKit
import Material

class DateDetailLabel: NewCustomButton {
    private let custimageView = UIImageView(frame: .zero)
    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.transformState = .init(highlighted: .init(scaleX: 0.95, y: 0.95), normal: .identity)
        setupView()
        backgroundColor = UIColor(named: "TASubElement")!.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        label.font = Fonts.heading5
        clipsToBounds = true
        custimageView.contentMode = .center
        label.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        label.text = text
    }
    
    private func setupView() {
        layout(label).top(5).bottom(5).trailing(12)
        layout(custimageView).centerY().trailing(label.anchor.leading, 5).leading(12)
        self.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func setImage(image: UIImage?) {
        custimageView.image = image
    }
    
}
