//
//  AllTagsTagCell.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import Material
import MGSwipeTableCell

class AllTagsTagCell: MGSwipeTableCell {
    static let reuseIdentifier = "alltagstagcell"
    
    private let overlayView = OverlaySelectionView()
    
    private var name: String!
    private var tasksCount: Int!
    
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 55)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, tasksCount: Int) {
        self.name = name
        self.tasksCount = tasksCount
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        layout(nameLabel).centerY().leading(20)
        
        let tasksCountView = CircleText(text: "\(tasksCount!)", bgColor: .hex("#00CE15"), widthHeight: 25)
        layout(tasksCountView).centerY().trailing(15).leading(nameLabel.anchor.trailing, 15) { _, _ in .greaterThanOrEqual }
        
        layout(overlayView).edges()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        overlayView.setHighlighted(highlighted, animated: true)
    }
}
