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
    private let addImage = UIImageView(image: Material.Icon.cm.add)
    private let centerView = UIView()
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
//        backgroundColor = UIColor(named: "TASpecial1")?.withAlphaComponent(0.4)
        layer.cornerRadius = 16
        clipsToBounds = true
        
        label.text = "Add Project".localizable()
        label.font = Fonts.heading3

        layout(centerView).center()
        centerView.layout(addImage).top().leading().bottom()
        centerView.layout(label).trailing().top().bottom().leading(addImage.anchor.trailing)
        layout(overlayView).edges()
        overlayView.selectedBackgroundColor = UIColor(named: "TASubElement")!
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        backgroundColor = SpecialColors.addSomethingBg
        addImage.tintColor = SpecialColors.addSomethingText
        label.textColor = SpecialColors.addSomethingText
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        overlayView.setHighlighted(highlighted, animated: true)
    }
}
