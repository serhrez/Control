//
//  PlusButton.swift
//  TodoApp
//
//  Created by sergey on 10.11.2020.
//

import Foundation
import UIKit
import Material

final class PlusView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#447bfe")
        containerView.layer.cornerRadius = 25
        layout(containerView).edges().width(50).height(50)
        
        let plus = UIImageView(image: UIImage(named: "check"))
        plus.tintColor = UIColor(named: "TAAltBackground")!
        plus.contentMode = .scaleAspectFit
        containerView.layout(plus).center().width(17).height(13)
    }
}
