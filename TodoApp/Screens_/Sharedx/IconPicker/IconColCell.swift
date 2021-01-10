//
//  IconColCell.swift
//  TodoApp
//
//  Created by sergey on 12.12.2020.
//

import Foundation
import UIKit
import Material
extension IconPicker {
class IconColCell: UICollectionViewCell {
    static let identifier = "iconcolcell"
    private let iconView = IconView()
    private let backgroundColorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#447bfe")
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 8
        view.layer.opacity = 0
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        layout(backgroundColorView).edges()
        layout(iconView).edges()
        iconView.iconFontSize = 48
        contentMode = .redraw
    }
    
    func initialConfigure(icon: Icon, isSelected: Bool) {
        iconView.configure(icon)
        backgroundColorView.layer.opacity = isSelected ? 1 : 0
    }
    
    func configure(isSelected: Bool) {
        UIView.animate(withDuration: Constants.animationDefaultDuration) {
            self.backgroundColorView.layer.opacity = isSelected ? 1 : 0
        }
    }
    
}
}
