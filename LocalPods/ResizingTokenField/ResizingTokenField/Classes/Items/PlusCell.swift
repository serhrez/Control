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
    var width: CGFloat { 27.75 }
    var height: CGFloat { 22.75 }
    var dotSize: CGFloat { 2.75 }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    private func setUp() {        
        layer.cornerRadius = 11
        backgroundColor = UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 0.1)
        layer.cornerRadius = height / 2
        layer.cornerCurve = .continuous
        layer.addSublayer(getDotLayer(offsetX: 0))
        layer.addSublayer(getDotLayer(offsetX: -dotSize * 2))
        layer.addSublayer(getDotLayer(offsetX: dotSize * 2))
    }
    
    func getDotLayer(offsetX: CGFloat) -> CALayer {
        let layer = CALayer()
        layer.cornerRadius = 1
        layer.backgroundColor = UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1).cgColor
        layer.frame = .init(x: width / 2 - dotSize / 2 + offsetX, y: height / 2 - dotSize / 2, width: dotSize, height: dotSize)
        return layer
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 0.2) : UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 0.1)
        }
    }
}
