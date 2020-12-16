//
//  PlannedTaskCell.swift
//  TodoApp
//
//  Created by sergey on 15.12.2020.
//

import Foundation
import UIKit
import Material
import ResizingTokenField

class PlannedTaskCell: UICollectionViewCell {
    static let reuseIdentifier = "plannedtaskcell"
    private let overlayView = OverlaySelectionView()
    private let checkboxView = AutoselectCheckboxView()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return label
    }()
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private let verticalHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        return stack
    }()
    
    private let verticalStackRight: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        stack.setContentHuggingPriority(.init(1), for: .horizontal)
        stack.alignment = .trailing
        return stack
    }()
    private let verticalStackRightIndicators: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .hex("#a4a4a4")
        label.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        label.setContentHuggingPriority(.init(1), for: .horizontal)

        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configure(text: String, date: Date, priority: Priority, tagName: String?, otherTags: Bool, isSelected: Bool, hasChecklist: Bool, onSelected: @escaping (Bool) -> Void) {
        verticalHorizontalStack.CSTremoveAllSubviews()
        verticalStackRightIndicators.CSTremoveAllSubviews()
        checkboxView.onSelected = onSelected
        checkboxView.configure(isChecked: isSelected)
        checkboxView.configure(priority: priority)
        nameLabel.text = text
        dateLabel.text = date.toFormat("hh:mm a")
        if let tagName = tagName {
            verticalHorizontalStack.addArrangedSubview(SingleTagView(text: tagName))
        }
        if otherTags {
            verticalHorizontalStack.addArrangedSubview(ThreeDotsTagView())
        }
        if hasChecklist {
            verticalStackRightIndicators.addArrangedSubview(getIndicatorImageView("list-check"))
        }
        if date != nil {
            verticalStackRightIndicators.addArrangedSubview(getIndicatorImageView("calendar"))
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
        layer.cornerRadius = 16
        clipsToBounds = true

        contentView.layout(checkboxView).centerY().width(22).leading(20)
        checkboxView.configure(isChecked: false)
        
        contentView.layout(verticalStackRight).centerY().trailing(21)
        
        verticalStack.addArrangedSubview(nameLabel)
        verticalStack.addArrangedSubview(verticalHorizontalStack)
        verticalStackRight.addArrangedSubview(dateLabel)
        verticalStackRight.addArrangedSubview(verticalStackRightIndicators)
        contentView.layout(verticalStack).leading(checkboxView.anchor.trailing, 11).centerY()
        contentView.layout(verticalStackRight).leading(verticalStack.anchor.trailing, 8)
        contentView.layout(overlayView).edges()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return .init(width: targetSize.width, height: 62)
    }
    
    override var isHighlighted: Bool {
        didSet {
            overlayView.setHighlighted(isHighlighted, animated: true)
        }
    }

}
