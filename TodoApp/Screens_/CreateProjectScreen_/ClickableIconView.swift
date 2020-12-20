//
//  CreateProjectIconView.swift
//  TodoApp
//
//  Created by sergey on 30.11.2020.
//

import Foundation
import UIKit
import Material

class ClickableIconView: UIView {
    let iconView = IconView()
    var onClick: () -> Void
    private lazy var onClickControl = OnClickControl(onClick: { [unowned self] in if !$0 { self.onClick() }  })
    init(onClick: @escaping () -> Void) {
        self.onClick = onClick
        super.init(frame: .zero)
        
        layout(iconView).edges()
        layout(onClickControl).edges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
