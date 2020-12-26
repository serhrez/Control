//
//  CalendarView.swift
//  TodoApp
//
//  Created by sergey on 25.11.2020.
//

import Foundation
import JTAppleCalendar
import Material
import AttributedLib
import SwiftDate

final class CalendarView: UIView {
    private let taLayout: CalendarViewLayout
    private let jct = JTACMonthView()
    private let formatter = DateFormatter()
    private let selectDate: (Date) -> Void
    private let datePriorities: (Date) -> (blue: Bool, orange: Bool, red: Bool, gray: Bool)
    private let alreadySelectedDate: Date
    
    init(layout: CalendarViewLayout = .default1, alreadySelectedDate: Date, selectDate: @escaping (Date) -> Void, datePriorities: @escaping (Date) -> (blue: Bool, orange: Bool, red: Bool, gray: Bool)) {
        self.taLayout = layout
        self.selectDate = selectDate
        self.datePriorities = datePriorities
        self.alreadySelectedDate = alreadySelectedDate
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = .white
        layout(jct).edges().width(taLayout.overallWidth).height(taLayout.overallHeight)
        // + 1 header with weekdays([S,M,T,W,T,F,S]) and +1 header with "< December 2020 >"
        jct.register(TAJTDateCell.self, forCellWithReuseIdentifier: TAJTDateCell.idq)
        jct.register(TAJTDateHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TAJTDateHeader")
        jct.calendarDataSource = self
        jct.calendarDelegate = self
        jct.cellSize = taLayout.cellWidthHeight + taLayout.columnsSpace
        jct.minimumLineSpacing = 0
        jct.minimumInteritemSpacing = taLayout.columnsSpace / 2
        jct.scrollDirection = .horizontal
        jct.backgroundColor = .clear
        jct.scrollingMode = .stopAtEachCalendarFrame
        jct.showsHorizontalScrollIndicator = false
        jct.scrollToDate(alreadySelectedDate, animateScroll: false)
    }
    var wasLastUpdateViaJctSelect: Bool = false
    func jctselectDate(_ date: Date) {
        wasLastUpdateViaJctSelect = true
        jct.selectDates([date])
        jct.scrollToDate(date)
    }

}


extension CalendarView: JTACMonthViewDataSource, JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        guard let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "TAJTDateHeader", for: indexPath) as? TAJTDateHeader else { return TAJTDateHeader() }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: range.start)
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: range.start)
        header.configure(month: month, year: year, onPrev: {
            calendar.isUserInteractionEnabled = false
            calendar.scrollToSegment(.previous) {
                calendar.isUserInteractionEnabled = true
            }
        }, onNext: {
            calendar.isUserInteractionEnabled = false
            calendar.scrollToSegment(.next) {
                calendar.isUserInteractionEnabled = true
            }
        })
        header.setTaLayout(taLayout: taLayout)
        return header
    }
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? TAJTDateCell else { return }
        let priorities = datePriorities(date)
        cell.configure(with: cellState, blue: priorities.blue, orange: priorities.orange, red: priorities.red, gray: priorities.gray)
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2025 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: TAJTDateCell.idq, for: indexPath) as? TAJTDateCell else { return TAJTDateCell() }
        let priorities = datePriorities(date)
        cell.configure(with: cellState, blue: priorities.blue, orange: priorities.orange, red: priorities.red, gray: priorities.gray)
        return cell
    }
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? TAJTDateCell else { return }
        let priorities = datePriorities(date)
        cell.configure(with: cellState, blue: priorities.blue, orange: priorities.orange, red: priorities.red, gray: priorities.gray)
        if !wasLastUpdateViaJctSelect {
        selectDate(date)
        }
        wasLastUpdateViaJctSelect = false
    }
    func calendar(_ calendar: JTACMonthView, shouldDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return true
    }
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell as? TAJTDateCell {
            let priorities = datePriorities(date)
            cell.configure(with: cellState, blue: priorities.blue, orange: priorities.orange, red: priorities.red, gray: priorities.gray)
        }
    }
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: taLayout.cellWidthHeight * 2)
    }

}

struct CalendarViewLayout {
    var availableWidth: CGFloat
    var cellColumns: CGFloat
    var cellRows: CGFloat
    var cellWidthHeight: CGFloat {
        min(availableWidth / cellColumns, 48)
    }
    var columnsSpace: CGFloat {
        let availableSpace = (availableWidth - cellWidthHeight * cellColumns) / cellColumns
        if availableSpace < 0.1 {
            return 0
        } else {
            return availableSpace
        }
    }
    var overallWidth: CGFloat {
        cellColumns * cellWidthHeight + (cellColumns - 1) * columnsSpace + columnsSpace
    }
    var overallHeight: CGFloat {
        cellWidthHeight * (cellRows + 2) // + 1 header with weekdays([S,M,T,W,T,F,S]) and +1 header with "< December 2020 >"
    }
    
    static let default1: CalendarViewLayout = CalendarViewLayout(availableWidth: UIScreen.main.bounds.width - 13 * 2 - 10 * 2, cellColumns: 7, cellRows: 6)
}
