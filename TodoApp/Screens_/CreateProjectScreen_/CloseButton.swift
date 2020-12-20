//
//  CloseButton.swift
//  TodoApp
//
//  Created by sergey on 30.11.2020.
//

import Foundation
import Material
import UIKit

class CloseButton: UIView {
    private let onClickControl: OnClickControl
    private let crossImageView = UIImageView(image: UIImage(named: "closebuttonsvg"))
    private let overlayView = OverlaySelectionView(frame: .zero)
    var onClicked: () -> Void
    init(onClicked: @escaping () -> Void) {
        self.onClicked = onClicked
        onClickControl = OnClickControl(onClick: { _ in })
        super.init(frame: .zero)
        onClickControl.onClick = clicked
        setupViews()
    }
    
    func setupViews() {
        clipsToBounds = true
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        heightAnchor.constraint(equalToConstant: 24).isActive = true
        overlayView.selectedBackgroundColor = UIColor.hex("#666666")
        layer.cornerRadius = 12
        layout(crossImageView).edges()
        layout(onClickControl).edges()
        layout(overlayView).edges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clicked(_ isClicked: Bool) {
        overlayView.setHighlighted(isClicked)
        if !isClicked {
            onClicked()
        }
    }
}
