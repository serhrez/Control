//
//  SubtaskCell.swift
//  TodoApp
//
//  Created by sergey on 19.11.2020.
//

import Foundation
import UIKit
import Material
import SwipeCellKit

final class SubtaskCell: SwipeTableViewCell {
    static let reuseIdentifier = "subtaskcell"
    private let checkboxView = AutoselectCheckboxView()
    private let nameLabel = UILabel()
    static let nameLabelLeadingTrailingSpace: CGFloat = 32
    static let nameLabelFont = Fonts.text
    static let nameLabelTopBottomSpace: CGFloat = 9.75
    var onSelected: ((Bool) -> Void)? {
        get { checkboxView.onSelected }
        set { checkboxView.onSelected = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, isDone: Bool) {
        nameLabel.text = name
        checkboxView.configure(isChecked: isDone)
    }
    
    func setupViews() {
        contentView.layout(checkboxView).top(10.75).leading()
        contentView.layout(nameLabel).top(SubtaskCell.nameLabelTopBottomSpace).leading(SubtaskCell.nameLabelLeadingTrailingSpace).trailing(SubtaskCell.nameLabelLeadingTrailingSpace)
            .bottom(SubtaskCell.nameLabelTopBottomSpace)
        contentView.backgroundColor = .clear
        backgroundColor = UIColor(named: "TABackground")!
        nameLabel.font = SubtaskCell.nameLabelFont
        nameLabel.textColor = UIColor(named: "TAHeading")!
        nameLabel.numberOfLines = 0
        selectionStyle = .none
    }
}
