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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor(hex: "#dfdfdf")?.withAlphaComponent(0.4)
        layer.cornerRadius = 16
        clipsToBounds = true
        
        let addImage = UIImageView(image: Material.Icon.cm.add)
        let centerView = UIView()
        let label = UILabel()
        
        addImage.tintColor = UIColor(named: "TASubElement")!
        
        label.text = "Add Project"
        label.textColor = UIColor(named: "TASubElement")!

        layout(centerView).center()
        centerView.layout(addImage).top().leading().bottom()
        centerView.layout(label).trailing().top().bottom().leading(addImage.anchor.trailing)
        layout(overlayView).edges()
        overlayView.selectedBackgroundColor = UIColor(named: "TASubElement")!
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        overlayView.setHighlighted(highlighted, animated: true)
    }
}
