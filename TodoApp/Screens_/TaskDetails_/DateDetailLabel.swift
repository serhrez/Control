//
//  DateDetailLabel.swift
//  TodoApp
//
//  Created by sergey on 21.11.2020.
//

import Foundation
import UIKit
import Material

class DateDetailLabel: UIView {
    private let imageView = UIImageView(frame: .zero)
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        backgroundColor = UIColor(named: "TASubElement")!.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        clipsToBounds = true
        imageView.contentMode = .center
        label.adjustsFontSizeToFitWidth = true
    }
    
    func setFontSize(size: CGFloat) {
        label.font = .systemFont(ofSize: size, weight: .semibold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        label.text = text
    }
    
    private func setupView() {
        layout(label).top(5).bottom(5).trailing(12)
        layout(imageView).centerY().trailing(label.anchor.leading, 5).leading(12)
    }
    
    func setImage(image: UIImage?) {
        imageView.image = image
    }
    
}
