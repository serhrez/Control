//
//  Iconview.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit

class IconView: UIView {
    var iconFontSize: CGFloat = 28
    
    private var previousView: UIView?
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ icon: Icon) {
        previousView?.removeFromSuperview()
        switch icon {
        case let .text(text):
            let textLabel = UILabel()
            textLabel.font = .systemFont(ofSize: iconFontSize)
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.text = text
            layout(textLabel).edges()
            previousView = textLabel
        case let .assetImage(assetImage, tintHex):
            var image = UIImage(named: assetImage)
            
            if let tint = tintHex {
                image = image?.withTintColor(.hex(tint))
            }
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            layout(imageView).edges()
            previousView = imageView
        default:
            break
        }

    }
}
