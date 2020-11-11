//
//  AllTasksToolbar.swift
//  TodoApp
//
//  Created by sergey on 10.11.2020.
//

import Foundation
import UIKit
import Material

final class AllTasksToolbar: UIView {
    static let estimatedHeight: CGFloat = 64
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let containerView = CustomButton(frame: .zero)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 30
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(hex: "#dfdfdf")?.cgColor
        layout(containerView).edges().height(Self.estimatedHeight)
        
        let label = UILabel()
        label.text = "Call to John Wick"
        label.textColor = UIColor(hex: "#a4a4a4")
        label.font = .systemFont(ofSize: 16)
        containerView.layout(label).leading(30).trailing(30).top(20).bottom(20)
        
        let plusView = PlusView()
        containerView.layout(plusView).trailing(7).top(7).bottom(7)
    }
}
