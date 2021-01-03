//
//  GappedCircle.swift
//  TodoApp
//
//  Created by sergey on 29.11.2020.
//

import Foundation
import UIKit
import Material
import SnapKit

class GappedCircle: UIView {
    let outerCircle: UIView = UIView()
    let middleCircle: UIView = UIView()
    let innerCircle: UIView = UIView()
    lazy var onClickView = OnClickControl(onClick: onClick)
    var onClick: (() -> Void) = { }
    var circleColor: UIColor {
        set {
            outerCircle.backgroundColor = newValue
            innerCircle.backgroundColor = newValue
        }
        get {
            outerCircle.backgroundColor ?? .clear
        }
    }
    private var totalWidthHeight: CGFloat
    init(circleColor: UIColor, widthHeight: CGFloat = 28) {
        self.totalWidthHeight = widthHeight
        super.init(frame: .zero)
        self.circleColor = circleColor
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        widthAnchor.constraint(equalToConstant: totalWidthHeight).isActive = true
        heightAnchor.constraint(equalToConstant: totalWidthHeight).isActive = true
        middleCircle.backgroundColor = UIColor(named: "TAAltBackground")!
        middleCircle.layer.opacity = 0
        layout(outerCircle).edges()
        layout(middleCircle).center()
        layout(innerCircle).center()
        setWidthAndHeight(widthHeight: totalWidthHeight, view: outerCircle)
        setWidthAndHeight(widthHeight: totalWidthHeight * 0.8571428571, view: middleCircle)
        setWidthAndHeight(widthHeight: totalWidthHeight * 0.636428571428571, view: innerCircle)
        [middleCircle, outerCircle, innerCircle].forEach {
            $0.clipsToBounds = true
        }
        layout(onClickView).edges()
    }
    
    func configure(isSelected: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.5 : 0) {
            if !isSelected {
                self.middleCircle.layer.opacity = 0
            } else {
                self.middleCircle.layer.opacity = 1
            }
        }
    }
    
    private func setWidthAndHeight(widthHeight: CGFloat, view: UIView) {
        view.snp.remakeConstraints { make in
            make.height.equalTo(widthHeight)
            make.width.equalTo(widthHeight)
        }
        view.layer.cornerRadius = widthHeight / 2
    }
    func onClick(_ state: Bool) {
        if !state {
            onClick()
        }
    }
}
