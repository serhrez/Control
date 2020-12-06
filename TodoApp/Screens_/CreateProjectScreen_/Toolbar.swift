//
//  CreateProjectVcToolbar.swift
//  TodoApp
//
//  Created by sergey on 30.11.2020.
//

import Foundation
import UIKit
import Material

extension CreateProjectVc {
    class Toolbar: UIView {
        
        init(onDateClicked: @escaping () -> Void, onTagClicked: @escaping () -> Void, onPriorityClicked: @escaping () -> Void) {
            super.init(frame: .zero)
            backgroundColor = .white
            let views: [UIView] = [
                UIView(),
                ClickableImage(imageName: "calendar-plus", onClick: onDateClicked),
                ClickableImage(imageName: "tag", onClick: onTagClicked),
                ClickableImage(imageName: "flag", onClick: onPriorityClicked),
                UIView()]
            let stack = UIStackView(arrangedSubviews: views)
            stack.distribution = .equalSpacing
            stack.axis = .horizontal
            layout(stack).leading().trailing().centerY()
            heightAnchor.constraint(equalToConstant: 53.18).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private class ClickableImage: UIView {
            init(imageName: String, onClick: @escaping () -> Void) {
                super.init(frame: .zero)
                let img = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                let imgView = UIImageView(image: img)
                imgView.tintColor = .hex("#A4A4A4")
                imgView.contentMode = .scaleAspectFit
                imgView.widthAnchor.constraint(equalToConstant: 18).isActive = true
                imgView.heightAnchor.constraint(equalToConstant: 18).isActive = true

                let onClickView = OnClickControl(onClick: {
                    imgView.tintColor = $0 ? UIColor.hex("#447bfe") : .hex("#A4A4A4")
                    if !$0 { onClick() }
                })
                layout(imgView).center()
                layout(onClickView).edges().width(32).height(26)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }
}
