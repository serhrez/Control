//
//  PlusCell.swift
//  ResizingTokenField
//
//  Created by sergey on 18.11.2020.
//  Copyright © 2020 Tadej Razborsek. All rights reserved.
//

import Foundation
import UIKit

class PlusCell: UICollectionViewCell {
    
    let imageView: UIImageView = UIImageView(image: UIImage(named: "Path", in: Bundle(for: NSClassFromString("ResizingTokenField.ResizingTokenField")!), with: .none))
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    private func setUp() {
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        layer.cornerRadius = 11
        backgroundColor = UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 0.1)
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 0.2) : UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 0.1)
        }
    }
}
