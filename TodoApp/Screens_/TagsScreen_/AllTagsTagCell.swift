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

class AllTagsTagCell: SwipeCollectionViewCell {
    static let reuseIdentifier = "alltagstagcell"
    
    private let overlayView = OverlaySelectionView()
    private let tasksCountView = CircleText(widthHeight: 25)
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, tasksCount: Int) {
        self.nameLabel.text = name
        self.tasksCountView.text = "\(tasksCount)"
    }
    
    func setupViews() {
        backgroundColor = UIColor(named: "TAAltBackground")!
        layer.cornerRadius = 16
        clipsToBounds = true
        tasksCountView.bgColor = .hex("#00CE15")
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        contentView.layout(nameLabel).centerY().leading(20)

        contentView.layout(tasksCountView).centerY().trailing(15).leading(nameLabel.anchor.trailing, 15) { _, _ in .greaterThanOrEqual }
        
        contentView.layout(overlayView).edges()
    }
    
    override var isHighlighted: Bool {
        didSet {
            overlayView.setHighlighted(isHighlighted, animated: true)
        }
    }
}
