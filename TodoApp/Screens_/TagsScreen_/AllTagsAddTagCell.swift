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
    private let addImage = UIImageView(image: Material.Icon.cm.add)
    private let centerView = UIView()
    private let label = UILabel()

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
        layer.cornerRadius = 16
        clipsToBounds = true
        
        label.text = "Add Tag".localizable()
        label.font = .systemFont(ofSize: 16, weight: .semibold)

        contentView.layout(centerView).center()
        centerView.layout(addImage).top().leading().bottom()
        centerView.layout(label).trailing().top().bottom().leading(addImage.anchor.trailing, 5)
        contentView.layout(overlayView).edges()
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        backgroundColor = SpecialColors.addSomethingBg
        addImage.tintColor = SpecialColors.addSomethingText
        label.textColor = SpecialColors.addSomethingText
    }
    
    override var isHighlighted: Bool {
        didSet {
            overlayView.setHighlighted(isHighlighted, animated: true)
        }
    }

}
