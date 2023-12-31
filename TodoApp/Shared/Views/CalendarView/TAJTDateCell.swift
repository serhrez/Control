//
//  DateCell.swift
//  TodoApp
//
//  Created by sergey on 25.11.2020.
//

import Foundation
import UIKit
import Material
import JTAppleCalendar
import SwiftDate

class TAJTDateCell: JTACDayCell {
    static let idq = "DateCell"
    let label = UILabel()
    private let selectedView = UIView()
    private var previousIndicatorsStack: UIView?
    
    private func getIndicatorsStack(colors: [UIColor]) -> UIStackView {
        func getIndicatorView(color: UIColor) -> UIView {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 3
            view.backgroundColor = color
            view.widthAnchor.constraint(equalToConstant: 6).isActive = true
            view.heightAnchor.constraint(equalToConstant: 6).isActive = true
            return view
        }
        let stack = UIStackView(arrangedSubviews: colors.map { getIndicatorView(color: $0) })
        stack.spacing = 1
        return stack
    }

    
    func configure(with cellState: CellState, blue: Bool, orange: Bool, red: Bool, gray: Bool) {
        label.text = cellState.text
        if cellState.date.isToday {
            label.textColor = UIColor(hex: "#447bfe")
        } else if cellState.dateBelongsTo == DateOwner.thisMonth && Date().dateAt(.startOfDay) <= cellState.date {
            label.textColor = UIColor(named: "TAHeading")
        } else {
            label.textColor = UIColor(named: "TASubElement")
        }
        
        selectedView.backgroundColor = Date().dateAt(.startOfDay) <= cellState.date ? UIColor.hex("#447bfe").withAlphaComponent(0.15) : UIColor.hex("#EF4439").withAlphaComponent(0.3)
        selectedView.layer.borderColor = Date().dateAt(.startOfDay) <= cellState.date ? UIColor.hex("#447bfe").cgColor : UIColor.hex("#EF4439").cgColor
        selectedView.isHidden = !cellState.isSelected
        previousIndicatorsStack?.removeFromSuperview()
        var indicatorColors: [UIColor] = []
        if gray {
            indicatorColors.append(UIColor(named: "TASubElement")!)
        }
        if blue {
            indicatorColors.append(UIColor(hex: "#447BFE")!)
        }
        if orange {
            indicatorColors.append(UIColor(hex: "#FF9900")!)
        }
        if red {
            indicatorColors.append(UIColor(hex: "#EF4439")!)
        }
        previousIndicatorsStack = getIndicatorsStack(colors: indicatorColors)
        layout(previousIndicatorsStack!).centerX().top(label.anchor.bottom, 4)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = Fonts.text
        selectedView.layer.cornerRadius = 10
        selectedView.layer.cornerCurve = .continuous
        selectedView.layer.borderWidth = 2.5
        selectedView.isHidden = true
        layout(selectedView).edges()
        layout(label).center()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
