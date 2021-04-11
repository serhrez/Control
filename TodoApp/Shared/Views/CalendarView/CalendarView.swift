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
    lazy var dateHeader = CalendarViewHeader(taLayout: taLayout)
    private let formatter = DateFormatter()
    private let selectDate: (Date) -> Void
    private let datePriorities: (Date) -> (blue: Bool, orange: Bool, red: Bool, gray: Bool)
    private let alreadySelectedDate: Date
    private var shouldChangeTitle: Bool = true
    
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
        layout(dateHeader).leading().trailing().top()
        layout(jct).leading().trailing().bottom().top(dateHeader.anchor.bottom).width(taLayout.overallWidth).height(taLayout.overallHeight)
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
        jct.scrollToDate(date, animateScroll: false)
    }

}


extension CalendarView: JTACMonthViewDataSource, JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if visibleDates.monthDates[0].date.isInside(date: Date(), granularity: .month) {
            dateHeader.chevronState = .normal
        } else {
            dateHeader.chevronState = .rotated
        }
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: range.start)
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: range.start)
        if shouldChangeTitle || range.start.isInside(date: Date(), granularity: .month) {
            dateHeader.configure(month: month, year: year, chevronClick: { [weak calendar, weak self] in
                calendar?.isUserInteractionEnabled = false
                self?.shouldChangeTitle = false
                calendar?.scrollToDate(Date()) {
                    calendar?.isUserInteractionEnabled = true
                    self?.shouldChangeTitle = true
                }
            })
        }
        return calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "TAJTDateHeader", for: indexPath)
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
        
        
        let startDate = alreadySelectedDate
        let endDate = formatter.date(from: "2025 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
        
        return parameters
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: TAJTDateCell.idq, for: indexPath) as? TAJTDateCell else { return TAJTDateCell() }
        let priorities = datePriorities(date)
        cell.configure(with: cellState, blue: priorities.blue, orange: priorities.orange, red: priorities.red, gray: priorities.gray)
        return cell
    }
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return Date().dateAt(.startOfDay) <= cellState.date
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
        return MonthSize(defaultSize: taLayout.cellWidthHeight * 0.45)
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
        cellWidthHeight * (cellRows + 0.45) // + 0.45 header with weekdays([S,M,T,W,T,F,S])
    }
    
    static let default1: CalendarViewLayout = CalendarViewLayout(availableWidth: UIScreen.main.bounds.width - 13 * 2 - 10 * 2, cellColumns: 7, cellRows: 6)
}
