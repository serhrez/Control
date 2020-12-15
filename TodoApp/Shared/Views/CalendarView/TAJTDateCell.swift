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
        if cellState.isSelected {
            label.textColor = .white
        } else
        if cellState.dateBelongsTo == DateOwner.thisMonth {
            label.textColor = UIColor(red: 0.142, green: 0.142, blue: 0.142, alpha: 1)
        } else {
            label.textColor = UIColor(red: 0.644, green: 0.644, blue: 0.644, alpha: 1)
        }
        selectedView.isHidden = !cellState.isSelected
        previousIndicatorsStack?.removeFromSuperview()
        var indicatorColors: [UIColor] = []
        if blue {
            indicatorColors.append(cellState.isSelected ? .white : UIColor(red: 0.267, green: 0.482, blue: 0.996, alpha: 1))
        }
        if orange {
            indicatorColors.append(UIColor(red: 1, green: 0.6, blue: 0, alpha: 1))
        }
        if red {
            indicatorColors.append(UIColor(red: 0.938, green: 0.266, blue: 0.223, alpha: 1))
        }
        if gray {
            indicatorColors.append(.hex("#A4A4A4"))
        }
        previousIndicatorsStack = getIndicatorsStack(colors: indicatorColors)
        layout(previousIndicatorsStack!).centerX().top(label.anchor.bottom, 4)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        selectedView.backgroundColor = UIColor(red: 0.267, green: 0.482, blue: 0.996, alpha: 1)
        selectedView.isHidden = true
        selectedView.layer.cornerRadius = 8
        layout(selectedView).edges()
        layout(label).center()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
