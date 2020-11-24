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
    
    private let checkboxView = AutoselectCheckboxView()
    private let nameLabel = UILabel()
    private var onSelected: ((Bool) -> Void)? {
        get { checkboxView.onSelected }
        set { checkboxView.onSelected = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, isSelected: Bool, onSelected: @escaping (Bool) -> Void) {
        self.nameLabel.text = name
        self.onSelected = onSelected
        self.checkboxView.configure(isChecked: isSelected)
    }
    
    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        contentView.layout(nameLabel).centerY().leading(20)

        contentView.layout(checkboxView).centerY().trailing(15).leading(nameLabel.anchor.trailing, 15) { _, _ in .greaterThanOrEqual }
        
    }
    
//    override var isHighlighted: Bool {
//        didSet {
//            overlayView.setHighlighted(isHighlighted, animated: true)
//        }
//    }
}
