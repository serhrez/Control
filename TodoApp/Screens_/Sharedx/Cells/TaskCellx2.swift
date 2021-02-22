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
        label.font = Fonts.heading4
        label.textColor = UIColor(named: "TAHeading")!
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
        
    func configure(text: String, date: Date?, tagName: String?, hasOtherTags: Bool, priority: Priority, hasChecklist: Bool, isChecked: Bool, onSelected: @escaping (Bool) -> Void) {
        verticalHorizontalStack.CSTremoveAllSubviews()
        indicators.CSTremoveAllSubviews()
        checkboxView.configure(isChecked: isChecked)
        checkboxView.configure(priority: priority)
        checkboxView.onSelected = onSelected
        nameLabel.text = text
        if let tagName = tagName {
            verticalHorizontalStack.addArrangedSubview(SingleTagView(text: tagName))
        }
        if hasOtherTags {
            verticalHorizontalStack.addArrangedSubview(ThreeDotsTagView())
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
        contentView.backgroundColor = UIColor(named: "TAAltBackground")!
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
    
    private func getDateLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = Fonts.heading6
        label.textColor = UIColor(named: "TASubElement")!
        label.text = text
        
        return label
    }

}

extension UIStackView {
    func CSTremoveAllSubviews() {
        UIView.performWithoutAnimation {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        }
    }
}
