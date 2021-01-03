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
        
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 80)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func configure(icon: Icon, name: String, progress: CGFloat, tasksCount: Int, color: UIColor) {
        iconView.configure(icon)
        nameLabel.text = name
        tasksCountView.bgColor = color
        tasksCountView.text = "\(tasksCount)"
        outerCircle.configure(color: color)
        progressCircle.configure(percent: progress, color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let iconView = IconView()
    private let nameLabel = UILabel()
    private let progressCircle = ProgressCircleView(widthHeight: 20)
    private lazy var outerCircle = OuterCircle(wrapped: progressCircle)

    func setupViews() {
        backgroundColor = UIColor(named: "TAAltBackground")!
        layer.cornerRadius = 16
        clipsToBounds = true
        let iconViewContainer = UIView()
        iconViewContainer.layout(iconView).centerX().top().bottom()
        layout(iconViewContainer).leading(23).centerY().width(28)
        
        nameLabel.font = .boldSystemFont(ofSize: 18)
        addSubview(outerCircle)
        layout(nameLabel).leading(63).centerY(iconView.anchor.centerY).trailing(outerCircle.anchor.leading, 7) { _, _ in .lessThanOrEqual }
        
        layout(tasksCountView).centerY(iconView.anchor.centerY).trailing(25).height(26)
        
        layout(outerCircle).centerY(iconView.anchor.centerY).trailing(tasksCountView.anchor.leading, 3)
        
        layout(overlayView).edges()
    }
        
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        overlayView.setHighlighted(highlighted, animated: true)
    }
}
