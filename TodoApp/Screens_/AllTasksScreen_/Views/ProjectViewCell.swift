//
//  ProjectViewCell.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material

final class ProjectViewCell: UITableViewCell {
    static let reuseIdentifier = "projectviewcell"
    // Should be the same as custombuttons overlay
    private let overlayView = OverlaySelectionView()
    private let tasksCountView = OvalText()
    
    private var icon: Icon!
    private var name: String!
    private var progress: CGFloat!
    private var tasksCount: Int!
    private var color: UIColor!
    
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 80)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(icon: Icon, name: String, progress: CGFloat, tasksCount: Int, color: UIColor) {
        self.icon = icon
        self.name = name
        self.progress = progress
        self.tasksCount = tasksCount
        self.color = color
        tasksCountView.bgColor = color
        tasksCountView.text = "\(tasksCount * 2)"
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        let iconViewContainer = UIView()
        let iconView = IconView()
        iconView.configure(icon)
        iconViewContainer.layout(iconView).centerX().top().bottom()
        layout(iconViewContainer).leading(23).centerY().width(28)
        
        let nameLabel = UILabel()
        nameLabel.font = .boldSystemFont(ofSize: 18)
        layout(nameLabel).leading(63).centerY(iconView.anchor.centerY)
        nameLabel.text = name
        
        layout(tasksCountView).centerY(iconView.anchor.centerY).trailing(25).height(26)
        
        let progressCircle = OuterCircle.getCircleWithProgress(percent: progress, color: color)
        layout(progressCircle).centerY(iconView.anchor.centerY).trailing(tasksCountView.anchor.leading, 3)
        
        layout(overlayView).edges()
    }
        
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        overlayView.setHighlighted(highlighted, animated: true)
    }
}
