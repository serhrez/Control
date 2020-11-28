//
//  TPVTextCell.swift
//  TodoApp
//
//  Created by sergey on 28.11.2020.
//

import Foundation
import UIKit
import Material
class TPVTextCell: UICollectionViewCell {
    static let reuseIdentifier = "tpvtextcell"
    let label = UILabel(frame: .zero)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        layout(label).edges()
        label.font = .systemFont(ofSize: 58, weight: .regular)
        label.textAlignment = .center
    }
    
    func configure(text: String) {
        label.text = text
    }
}
