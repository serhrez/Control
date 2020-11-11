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

final class ProjectViewCell: UIView {
    static let reuseIdentifier = "projectviewcell"
    
    private let icon: Icon
    private let name: String
    private let progress: CGFloat
    private let tasksCount: Int
    private let color: UIColor
    
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 80)
    }
    
    init(icon: Icon, name: String, progress: CGFloat, tasksCount: Int, color: UIColor) {
        self.icon = icon
        self.name = name
        self.progress = progress
        self.tasksCount = tasksCount
        self.color = color
        super.init(frame: .zero)
//        super.init(style: .default, reuseIdentifier: Self.reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        let iconView = IconView(icon)
        layout(iconView).leading(25).centerY()
        
        let nameLabel = UILabel()
        nameLabel.font = .boldSystemFont(ofSize: 18)
        layout(nameLabel).leading(63).centerY(iconView.anchor.centerY)
        nameLabel.text = name
        
        let tasksCountView = CircleText(text: "\(tasksCount)", bgColor: color)
        layout(tasksCountView).centerY(iconView.anchor.centerY).trailing(25).width(25).height(25)
        
        let progressCircle = OuterCircle.getCircleWithProgress(percent: progress, color: color)
        layout(progressCircle).centerY(iconView.anchor.centerY).trailing(tasksCountView.anchor.leading, 3)
    }
}
