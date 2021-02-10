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
    static let height = 44
    private let checkboxView = AutoselectCheckboxView()
    private let nameLabel = UILabel()
    
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
        contentView.layout(checkboxView).centerY().leading()
        contentView.layout(nameLabel).centerY().leading(32).trailing(32)
        contentView.backgroundColor = .clear
        backgroundColor = UIColor(named: "TAAltBackground")!
        nameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        nameLabel.textColor = UIColor(named: "TAHeading")!
        selectionStyle = .none
    }
}
