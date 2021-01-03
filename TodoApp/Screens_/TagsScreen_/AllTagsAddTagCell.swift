//
//  AllTagsAddTagCell.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import Material

class AllTagsAddTagCell: UICollectionViewCell {
    static let reuseIdentifier = "alltagsaddtagcell"
    
    private let overlayView = OverlaySelectionView()
    override var intrinsicContentSize: CGSize {
        .init(width: .zero, height: 55)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        label.text = "Add Tag"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(named: "TASubElement")!

        contentView.layout(centerView).center()
        centerView.layout(addImage).top().leading().bottom()
        centerView.layout(label).trailing().top().bottom().leading(addImage.anchor.trailing, 5)
        contentView.layout(overlayView).edges()
    }
    
    override var isHighlighted: Bool {
        didSet {
            overlayView.setHighlighted(isHighlighted, animated: true)
        }
    }

}
