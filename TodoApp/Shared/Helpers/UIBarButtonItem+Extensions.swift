//
//  UIBarButtonItem+Extensions.swift
//  TodoApp
//
//  Created by sergey on 20.02.2021.
//

import Foundation
import UIKit
import AttributedLib

extension UIBarButtonItem {
    static func customInit(image: UIImage, title: String, primaryAction: UIAction) -> UIBarButtonItem {
        let button = NewCustomButton(type: .custom, primaryAction: primaryAction)
//        button.setImage(image, for: .normal)
//        button.setTitle(title, for: .normal)
        button.opacityState = .init(highlighted: 0.5, normal: 1)
        let imgView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imgView.tintColor = UIColor(named: "TAHeading")!
        imgView.contentMode = .center
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(named: "TAHeading")!
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.02
        titleLabel.attributedText = title.at.attributed { attr in
            attr.paragraphStyle(paragraphStyle)
        }
        button.layout(imgView).leading().centerY().width(24).height(24)
        button.layout(titleLabel).trailing().centerY().leading(imgView.anchor.trailing, 6)
        return UIBarButtonItem(customView: button)
    }
    
    static func customInit(title: String, primaryAction: UIAction) -> UIBarButtonItem {
        let button = NewCustomButton(type: .custom, primaryAction: primaryAction)
        button.opacityState = .init(highlighted: 0.5, normal: 1)
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(hex: "#447BFE")!
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.adjustsFontSizeToFitWidth = true
        button.layout(titleLabel).edges()
        return UIBarButtonItem(customView: button)
    }

    
}
