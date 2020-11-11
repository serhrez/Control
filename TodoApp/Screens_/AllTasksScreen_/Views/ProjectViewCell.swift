//
//  ProjectViewCell.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material
import MGSwipeTableCell

final class ProjectViewCell: MGSwipeTableCell {
    static let reuseIdentifier = "projectviewcell"
    
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
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        let iconViewContainer = UIView()
        let iconView = IconView(icon)
        iconViewContainer.layout(iconView).centerX().top().bottom()
        layout(iconViewContainer).leading(23).centerY().width(28)
        
        let nameLabel = UILabel()
        nameLabel.font = .boldSystemFont(ofSize: 18)
        layout(nameLabel).leading(63).centerY(iconView.anchor.centerY)
        nameLabel.text = name
        
        let tasksCountView = CircleText(text: "\(tasksCount!)", bgColor: color)
        layout(tasksCountView).centerY(iconView.anchor.centerY).trailing(25).width(25).height(25)
        
        let progressCircle = OuterCircle.getCircleWithProgress(percent: progress, color: color)
        layout(progressCircle).centerY(iconView.anchor.centerY).trailing(tasksCountView.anchor.leading, 3)
    }
}
