//
//  ArchiveCell.swift
//  TodoApp
//
//  Created by sergey on 16.12.2020.
//

import Foundation
import UIKit
import Material
import SwipeCellKit

class ArchiveCell: SwipeCollectionViewCell {
    static let reuseIdentifier = "archiveCell"
    private let overlayView = OverlaySelectionView()
    private let checkboxView = CheckboxViewArchive()
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
    
    func update(state: CheckboxViewArchive.State) {
        checkboxView.configure(state: state)
    }
        
    func configure(text: String, date: Date?, tagName: String?, hasChecklist: Bool, state: CheckboxViewArchive.State, clickedWithState: @escaping (CheckboxViewArchive.State) -> Void) {
        verticalHorizontalStack.CSTremoveAllSubviews()
        indicators.CSTremoveAllSubviews()
        checkboxView.onStateChanged = clickedWithState
        checkboxView.configure(state: state)
        nameLabel.text = text
        if let tagName = tagName {
            verticalHorizontalStack.addArrangedSubview(SingleTagView(text: tagName))
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
        imageView.tintColor = UIColor(named: "TASubElement")!
        return imageView
    }
    
    func setupViews() {
        contentView.backgroundColor = UIColor(named: "TAAltBackground")
        layer.cornerRadius = 16
        clipsToBounds = true

        contentView.layout(checkboxView).centerY().width(22).height(22).leading(20)
        
        contentView.layout(indicators).centerY().trailing(21)
        
        verticalStack.addArrangedSubview(nameLabel)
        verticalStack.addArrangedSubview(verticalHorizontalStack)
        contentView.layout(verticalStack).leading(checkboxView.anchor.trailing, 11).trailing(indicators.anchor.leading, 8) { _, _ in .lessThanOrEqual }.centerY()
        
        contentView.layout(overlayView).edges()
        contentView.heightAnchor.constraint(equalToConstant: 62).isActive = true
    }
    
    override var isHighlighted: Bool {
        didSet {
            overlayView.setHighlighted(isHighlighted, animated: true)
        }
    }
    
    private func getDateLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(named: "TASubElement")!
        label.text = text
        
        return label
    }

}
