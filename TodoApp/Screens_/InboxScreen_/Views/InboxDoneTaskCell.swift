//
//  InboxDoneTaskCell.swift
//  TodoApp
//
//  Created by sergey on 16.11.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

class InboxDoneTaskCell: UICollectionViewCell {
    static let reuseIdentifier = "inboxdonetaskcell"
    
    private let overlayView = OverlaySelectionView()
    private let checkboxView = CheckboxView()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, onSelected: @escaping () -> Void) {
        checkboxView.onSelected = onSelected
        nameLabel.attributedText = text.at.attributed { attr in
            attr.foreground(color: .hex("#A4A4A4")).strikeThroughStyle(.single)
        }
    }
    
    func setupViews() {
        contentView.layout(checkboxView).centerY().leading(20)
        checkboxView.configure(isChecked: true)
        contentView.layout(nameLabel).leading(checkboxView.anchor.trailing, 11).trailing(20) { _, _ in .lessThanOrEqual }.centerY()
        nameLabel.numberOfLines = 1
        contentView.layer.cornerRadius = 16
    }
    //    private let
}
