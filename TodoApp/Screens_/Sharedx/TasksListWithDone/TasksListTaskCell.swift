//
//  TaskCellx1.swift
//  TodoApp
//
//  Created by sergey on 16.11.2020.
//

import Foundation
import UIKit
import Material
import ResizingTokenField
import SwipeCellKit

class TasksListTaskCell: SwipeCollectionViewCell {
    static let reuseIdentifier = "taskslisttaskcell"
    private let overlayView = OverlaySelectionView()
    private let checkboxView = CheckboxView()
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
        
    func configure(text: String, date: Date?, tagName: String?, otherTags: Bool, priority: Priority, hasChecklist: Bool, onSelected: @escaping () -> Void) {
        verticalHorizontalStack.CSTremoveAllSubviews()
        indicators.CSTremoveAllSubviews()
        checkboxView.onSelected = onSelected
        checkboxView.configure(priority: priority)
        nameLabel.text = text
        if let tagName = tagName {
            verticalHorizontalStack.addArrangedSubview(SingleTagView(text: tagName))
        }
        if otherTags {
            verticalHorizontalStack.addArrangedSubview(ThreeDotsTagView())
        }
        if let date = date {
            verticalHorizontalStack.addArrangedSubview(getDateLabel(text: DateFormatter.str(from: date)))
        }
        if hasChecklist {
            indicators.addArrangedSubview(getIndicatorImageView("list-check"))
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
        contentView.layer.backgroundColor = UIColor.hex("#ffffff").cgColor
        // Had to create second contentView so we have separat
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = .clear
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

    private func getDateLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .hex("#A4A4A4")
        label.text = text
        
        return label
    }

}
