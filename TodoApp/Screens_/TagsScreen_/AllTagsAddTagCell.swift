//
//  AllTagsAddTagCell.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import Material

class AllTagsAddTagCell: UITableViewCell {
    static let reuseIdentifier = "alltagsaddtagcell"
    
    private let overlayView = OverlaySelectionView()
    
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 55)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        label.text = "Add Tag"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(hex: "#a4a4a4")

        layout(centerView).center()
        centerView.layout(addImage).top().leading().bottom()
        centerView.layout(label).trailing().top().bottom().leading(addImage.anchor.trailing, 5)
        layout(overlayView).edges()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        overlayView.setHighlighted(highlighted, animated: true)
    }
}
