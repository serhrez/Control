//
//  DoneTasksListTaskCell.swift
//  TodoApp
//
//  Created by sergey on 16.11.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib
import SwipeCellKit

class DoneTasksListTaskCell: SwipeCollectionViewCell {
    static let reuseIdentifier = "donetaskslisttaskcell"
    
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
        nameLabel.attributedText = text.at.attributed { attr in
            attr.foreground(color: UIColor(named: "TASubElement")!).strikeThroughStyle(.single)
        }
    }
    
    func setupViews() {
        contentView.layout(checkboxView).centerY().leading(20)
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = .clear

        checkboxView.configure(isChecked: true)
        contentView.layout(nameLabel).centerY().leading(checkboxView.anchor.trailing, 11).trailing(20).centerY()
        nameLabel.numberOfLines = 1
        backgroundColor = .clear
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        contentView.backgroundColor = UIColor(named: "TABorder")!.withAlphaComponent(isWhiteTheme ? 0.3 : 1)
    }
}
