//
//  TaskCellx2.swift
//  TodoApp
//
//  Created by sergey on 28.11.2020.
//

import Foundation
import UIKit
import Material
import ResizingTokenField

class TaskCellx2: UICollectionViewCell {
    static let reuseIdentifier = "taskcellx2"
    
    private let overlayView = OverlaySelectionView()
    private let checkboxView = AutoselectCheckboxView()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)

        return label
    }()
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1
        return stack
    }()
    private let verticalHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        return stack
    }()
    private let indicators: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configure(text: String, date: Date?, tagName: String?, hasChecklist: Bool, isChecked: Bool, onSelected: @escaping (Bool) -> Void) {
        verticalHorizontalStack.CSTremoveAllSubviews()
        indicators.CSTremoveAllSubviews()
        checkboxView.configure(isChecked: isChecked)
        checkboxView.onSelected = onSelected
        nameLabel.text = text
        if let tagName = tagName {
            verticalHorizontalStack.addArrangedSubview(TagView(text: tagName))
        }
        if let date = date {
            verticalHorizontalStack.addArrangedSubview(getDateLabel(text: DateFormatter.str(from: date)))
        }
        if hasChecklist {
            indicators.addArrangedSubview(getIndicatorImageView("list-check"))
        }
        if date != nil {
            indicators.addArrangedSubview(getIndicatorImageView("calendar"))
        }
        verticalHorizontalStack.addArrangedSubview(UIView()) // works like spacer, so that view will be stretched to the left
    }
    
    private func getIndicatorImageView(_ name: String) -> UIImageView {
        let image = UIImage(named: name)
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 11).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 11).isActive = true
        imageView.tintColor = .hex("#A4A4A4")
        return imageView
    }
    
    func setupViews() {
        contentView.layer.backgroundColor = UIColor.white.cgColor
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.layout(checkboxView).centerY().width(22).leading(20)
        checkboxView.configure(isChecked: false)
        
        contentView.layout(indicators).centerY().trailing(21)
        
        verticalStack.addArrangedSubview(nameLabel)
        verticalStack.addArrangedSubview(verticalHorizontalStack)
        contentView.layout(verticalStack).leading(checkboxView.anchor.trailing, 11).trailing(indicators.anchor.leading, 8) { _, _ in .lessThanOrEqual }.centerY()

        
        contentView.layout(overlayView).edges()
    }
                
    override var isHighlighted: Bool {
        didSet {
            overlayView.setHighlighted(isHighlighted, animated: true)
        }
    }
    
    class TagView: UIView {
        let label = UILabel(frame: .zero)
        var text: String {
            get { label.text ?? "" }
            set { label.text = newValue }
        }
        init(text: String) {
            super.init(frame: .zero)
            self.text = text
            layout(label).leading(8).trailing(8).top(2).bottom(2)
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            backgroundColor = UIColor.hex("#00CE15").withAlphaComponent(0.1)
            label.textColor = .hex("#00CE15")
            layer.cornerRadius = 12
            layer.cornerCurve = .continuous
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    private func getDateLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .hex("#A4A4A4")
        label.text = text
        
        return label
    }

}

extension UIStackView {
    func CSTremoveAllSubviews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}
