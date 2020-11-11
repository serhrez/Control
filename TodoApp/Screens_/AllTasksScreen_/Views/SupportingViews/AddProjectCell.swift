//
//  AddProjectCell.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material

final class AddProjectCell: UIView {
    static let height: CGFloat = 80
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let containerView = UIView()
        containerView.backgroundColor = .red
        containerView.backgroundColor = UIColor(hex: "#dfdfdf")?.withAlphaComponent(0.4)
        containerView.layer.cornerRadius = 16
        layout(containerView).edges().height(Self.height).width(200)
        
        let addImage = UIImageView(image: Material.Icon.cm.add)
        let centerView = UIView()
        let label = UILabel()
        
        addImage.tintColor = UIColor(hex: "#a4a4a4")
        
        label.text = "Add Project"
        label.textColor = UIColor(hex: "#a4a4a4")

        layout(centerView).center()
        centerView.layout(addImage).top().leading().bottom()
        centerView.layout(label).trailing().top().bottom().leading(addImage.anchor.trailing)
    }
}
