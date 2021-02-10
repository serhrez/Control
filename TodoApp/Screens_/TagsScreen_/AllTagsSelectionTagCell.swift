//
//  AllTagsTagCell.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import Material
import SwipeCellKit

class AllTagsSelectionTagCell: SwipeCollectionViewCell {
    static let reuseIdentifier = "alltagsselectiontagcell"
    
    private let overlayView = OverlaySelectionView()
    private let checkboxView = CheckboxView()
    private let nameLabel = UILabel()
    private var onSelected: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    var isReallySelected: Bool = false {
        didSet {
            self.checkboxView.configure(isChecked: isReallySelected)
        }
    }
    override var isSelected: Bool {
        didSet {
            guard isSelected else { return }
            isReallySelected.toggle()
            self.checkboxView.configure(isChecked: isReallySelected)
            self.onSelected?(isReallySelected)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, isSelected selectedd: Bool, onSelected: @escaping (Bool) -> Void) {
        self.nameLabel.text = name
        self.onSelected = onSelected
        self.isReallySelected = selectedd
    }
    
    func setupViews() {
        backgroundColor = UIColor(named: "TAAltBackground")!
        layer.cornerRadius = 16
        clipsToBounds = true
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor(named: "TAHeading")!
        contentView.layout(nameLabel).centerY().leading(20)

        contentView.layout(checkboxView).centerY().trailing(15).leading(nameLabel.anchor.trailing, 15) { _, _ in .greaterThanOrEqual }
        contentView.layout(overlayView).edges()
        checkboxView.isUserInteractionEnabled = false
    }
    
    override var isHighlighted: Bool {
        didSet {
            overlayView.setHighlighted(isHighlighted, animated: true)
        }
    }
}
