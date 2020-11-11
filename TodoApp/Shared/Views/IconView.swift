//
//  Iconview.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit

class IconView: UIView {
    private let icon: Icon
    init(_ icon: Icon) {
        self.icon = icon
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        switch icon {
        case let .text(text):
            let textLabel = UILabel()
            textLabel.font = .systemFont(ofSize: 28)
            textLabel.text = text
            layout(textLabel).edges()
        case let .assetImage(assetImage, tintHex):
            var image = UIImage(named: assetImage)
            if let tint = tintHex {
                image = image?.withTintColor(.hex(tint))
            }
            let imageView = UIImageView(image: image)
            layout(imageView).edges()
        default:
            break
        }
    }
}
