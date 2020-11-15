//
//  AddProjectCell.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material

final class AddProjectCell: UITableViewCell {
    static let reuseIdentifier = "AddProjectCell"
    private let overlayView = OverlaySelectionView()
    
    func configure() {
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = UIColor(hex: "#dfdfdf")?.withAlphaComponent(0.4)
        layer.cornerRadius = 16
        clipsToBounds = true
        
        let addImage = UIImageView(image: Material.Icon.cm.add)
        let centerView = UIView()
        let label = UILabel()
        
        addImage.tintColor = UIColor(hex: "#a4a4a4")
        
        label.text = "Add Project"
        label.textColor = UIColor(hex: "#a4a4a4")

        layout(centerView).center()
        centerView.layout(addImage).top().leading().bottom()
        centerView.layout(label).trailing().top().bottom().leading(addImage.anchor.trailing)
        layout(overlayView).edges()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        overlayView.setHighlighted(highlighted, animated: true)
    }
}
