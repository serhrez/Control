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

class InboxDoneTaskCell: UITableViewCell {
    static let reuseIdentifier = "inboxdonetaskcell"
    
    private let overlayView = OverlaySelectionView()
    private let checkboxView = CheckboxView()
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, onSelected: @escaping () -> Void) {
        checkboxView.onSelected = onSelected
        nameLabel.attributedText = text.at.attributed { attr in
            attr.foreground(color: .hex("#A4A4A4")).strikeThroughStyle(.single).lineSpacing(8)
        }
    }
    
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.layout(checkboxView).top(2).bottom() { _, _ in .lessThanOrEqual }.leading(20)
        checkboxView.configure(isChecked: true)
        contentView.layout(nameLabel).top().bottom().leading(checkboxView.anchor.trailing, 11).trailing(20) { _, _ in .lessThanOrEqual }.centerY()
        nameLabel.numberOfLines = 0
        contentView.layer.cornerRadius = 16
        backgroundColor = .clear
    }
}
