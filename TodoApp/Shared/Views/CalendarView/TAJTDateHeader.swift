//
//  TAJTDateHeader.swift
//  TodoApp
//
//  Created by sergey on 25.11.2020.
//

import Foundation
import UIKit
import Material
import JTAppleCalendar
import AttributedLib

class CalendarViewHeader: UIView {
    var onPrev: (() -> Void)?
    var onNext: (() -> Void)?

    lazy var leftChevronButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(leftClicked), for: .touchUpInside)
        button.setImage(UIImage(named: "chevron-left"), for: .normal)
        return button
    }()
    lazy var rightChevronButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(rightClicked), for: .touchUpInside)
        button.setImage(UIImage(named: "chevron-right"), for: .normal)
        return button
    }()
    lazy var titleLabel: UILabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(taLayout: CalendarViewLayout) {
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: taLayout.cellWidthHeight).isActive = true
        layout(leftChevronButton).top().bottom().leading().width(taLayout.cellWidthHeight)
        layout(rightChevronButton).top().bottom().trailing().width(taLayout.cellWidthHeight)
        layout(titleLabel).center()
    }
        
    func configure(month: String, year: String, onPrev: @escaping () -> Void, onNext: @escaping () -> Void) {
        self.onPrev = onPrev
        self.onNext = onNext
        UIView.transition(with: titleLabel, duration: Constants.animationDefaultDuration, options: [.transitionCrossDissolve]) {
            self.titleLabel.attributedText = month.at.attributed { attr in
                attr.foreground(color: UIColor(named: "TAHeading")!).font(.systemFont(ofSize: 18, weight: .semibold))
            } + " \(year)".at.attributed { attr in
                attr.foreground(color: .hex("#447BFE")).font(.systemFont(ofSize: 18, weight: .semibold))
            }
        }
    }
    @objc func leftClicked() {
        onPrev?()
    }
    @objc func rightClicked() {
        onNext?()
    }

}

class TAJTDateHeader: JTACMonthReusableView {

    let weekDaysStack: UIStackView = {
        func getView(text: String) -> UIView {
            let view = UIView()
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            view.layout(label).center()
            return view
        }
        let stack = UIStackView(arrangedSubviews: ["S", "M", "T", "W", "T", "F", "S"].map { getView(text: $0) })
        stack.distribution = .fillEqually
        return stack
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout(weekDaysStack).edges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
