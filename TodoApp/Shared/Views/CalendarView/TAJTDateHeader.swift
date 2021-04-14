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
    var chevronClick: (() -> Void)?

    lazy var titleLabel: UILabel = UILabel()
    let titleView: NewCustomButton = {
        let button = NewCustomButton()
        button.vibrateOnClick = true
        button.pointInsideInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        
        return button
    }()
    let chevronButton: UIImageView = {
        let view = UIImageView(image: UIImage(named: "chevronx"))
        return view
    }()
    
    var chevronState: ChevronState = .normal {
        didSet {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                switch self.chevronState {
                case .normal:
                    self.chevronButton.transform = .identity
                case .rotated:
                    self.chevronButton.transform = .init(rotationAngle: -.pi / 2)
                }
            }
        }
    }
    private let isSecondLook: Bool
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(taLayout: CalendarViewLayout, isSecondLook: Bool) {
        self.isSecondLook = isSecondLook
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: 48).isActive = true
        if isSecondLook {
            layout(titleView).centerY().leading(24 - PlannedVc.calendarInset)
        } else {
            layout(titleView).center()
        }
        titleView.layout(titleLabel).leading().top().bottom()
        titleView.layout(chevronButton).trailing().centerY().leading(titleLabel.anchor.trailing, 4)
        titleView.addTarget(self, action: #selector(chevronClicked), for: .touchUpInside)
        titleView.opacityState = .opacity()
    }
        
    func configure(month: String, year: String, chevronClick: @escaping () -> Void) {
        self.chevronClick = chevronClick
        self.titleLabel.attributedText = month.at.attributed { attr in
            attr.foreground(color: UIColor(named: "TAHeading")!).font(isSecondLook ? Fonts.custHeading1 : Fonts.heading3)
        } + " \(year)".at.attributed { attr in
            attr.foreground(color: .hex("#447BFE")).font(Fonts.heading3)
        }
    }
    
    @objc func chevronClicked() {
        chevronState = .normal
        chevronClick?()
    }

}

extension CalendarViewHeader {
    enum ChevronState {
        case rotated
        case normal
    }
}

class TAJTDateHeader: JTACMonthReusableView {

    let weekDaysStack: UIStackView = {
        func getView(text: String) -> UIView {
            let view = UIView()
            let label = UILabel()
            label.text = text
            label.font = Fonts.heading5
            label.textColor = UIColor(named: "TASubElement")!
            view.layout(label).center()
            return view
        }
        let stack = UIStackView(arrangedSubviews: [
            "Monday-One-Letter".localizable(comment: "Monday"),
            "Tuesday-One-Letter".localizable(comment: "Tuesday"),
            "Wednesday-One-Letter".localizable(comment: "Wendnesday"),
            "Thursday-One-Letter".localizable(comment: "Thursday"),
            "Friday-One-Letter".localizable(),
            "Saturday-One-Letter".localizable(),
            "Sunday-One-Letter".localizable()
        ].map { getView(text: $0) })
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
