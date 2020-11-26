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

class TAJTDateHeader: JTACMonthReusableView {
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

    lazy var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layout(titleLabel).center()
        return view
    }()
    @objc func leftClicked() {
        onPrev?()
    }
    @objc func rightClicked() {
        onNext?()
    }
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
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topView, weekDaysStack])
        stack.axis = .vertical
        return stack
    }()
    var onPrev: (() -> Void)?
    var onNext: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout(stack).edges()
    }
    func setTaLayout(taLayout: CalendarViewLayout) {
        topView.heightAnchor.constraint(equalToConstant: taLayout.cellWidthHeight).isActive = true
        topView.layout(leftChevronButton).top().bottom().leading().width(taLayout.cellWidthHeight)
        topView.layout(rightChevronButton).top().bottom().trailing().width(taLayout.cellWidthHeight)
    }
    
    func configure(month: String, year: String, onPrev: @escaping () -> Void, onNext: @escaping () -> Void) {
        self.onPrev = onPrev
        self.onNext = onNext
        titleLabel.attributedText = month.at.attributed { attr in
            attr.foreground(color: UIColor(red: 0.142, green: 0.142, blue: 0.142, alpha: 1)).font(.systemFont(ofSize: 18, weight: .semibold))
        } + " \(year)".at.attributed { attr in
            attr.foreground(color: UIColor(red: 0.267, green: 0.482, blue: 0.996, alpha: 1)).font(.systemFont(ofSize: 18, weight: .semibold))
        }
        print("month: \(month) year: \(year)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
