//
//  CalendarVc.swift
//  TodoApp
//
//  Created by sergey on 25.11.2020.
//

import Foundation
import UIKit
import Material
import RxSwift
import SwiftDate
import AttributedLib

final class CalendarVc2: UIViewController {
    private let bag = DisposeBag()
    private let viewModel: CalendarVcVm
    private lazy var calendarView = CalendarView(alreadySelectedDate: viewModel.date.value.0 ?? .init(), selectDate: { [weak self] date in
        self?.viewModel.selectDayFromJct(date)
    }, datePriorities: { [weak self] date in
        guard let self = self else { return (false, false, false, false) }
        return self.viewModel.datePriorities(date)
    })
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TABorder")!
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    private let separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TABorder")!
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    lazy var todayButton: CalendarButton1 = CalendarButton1(image: "today", text: "Today".localizable(), imageWidth: 30, onClick: { [weak self] in
        self?.viewModel.clickedToday()
    })
    lazy var tomorrowButton: CalendarButton1 = {
        let button = CalendarButton1(image: "calendar-plus2", text: "Tomorrow".localizable(), imageWidth: 28, onClick: { [weak self] in
            self?.viewModel.clickedTomorrow()
        })
        button.imageView2.tintColor = .hex("#447BFE")
        return button
    }()
    lazy var nextMondayButton: CalendarButton1 = CalendarButton1(image: "brightness-up", text: "Next Monday".localizable(), isOneLine: false, imageWidth: 26, onClick: { [weak self] in
        self?.viewModel.clickedNextMonday()
    })
    lazy var eveningButton = CalendarButton1(image: "moon", text: "Evening".localizable(), imageWidth: 25, onClick: { [weak self] in
        self?.viewModel.clickedEvening()
    })
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todayButton, tomorrowButton, nextMondayButton, eveningButton])
        stack.distribution = .fillEqually
        stack.alignment = .top
        return stack
    }()
    private let scrollView = UIScrollView()
    private lazy var clearDoneButtons = ClearDoneButtons(clear: { [weak self] in
        guard let self = self else { return }
        self.closeView()
    }, done: { [weak self] in
        self?.done()
    })
    lazy var timeButton = CalendarButton2(image: "alarm", text: "Time".localizable(), onClick: { [weak self] in
        self?.clickedTime()
    })
    lazy var reminderButton = CalendarButton2(image: "bell", text: "Reminder".localizable(), onClick: { [weak self] in
        self?.clickedReminder()
    })
    lazy var repeatButton = CalendarButton2(image: "repeat", text: "Repeat".localizable(), onClick: { [weak self] in
        self?.clickedRepeat()
    })
    private let onDone: (Date?, Reminder?, Repeat?) -> Void
    init(viewModel: CalendarVcVm, onDone: @escaping (Date?, Reminder?, Repeat?) -> Void) {
        self.viewModel = viewModel
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applySharedNavigationBarAppearance()
        setupViews()
        setupBinding()
    }
    
    private func setupBinding() {
        viewModel.date.subscribe(onNext: { [weak self] date in
            guard let self = self else { return }
            self.timeButton.configure(selectedText: date.0?.toFormat("HH:mm"))
            if !(date.1 ?? false) {
                if let date = date.0 {
                    self.calendarView.jctselectDate(date)
                }
            }
        }).disposed(by: bag)
        viewModel.reminder.subscribe(onNext: { [weak self] reminder in
            guard let self = self else { return }
            self.reminderButton.configure(selectedText: reminder?.description)
        }).disposed(by: bag)
        viewModel.repeat.subscribe(onNext: { [weak self] `repeat` in
            guard let self = self else { return }
            self.repeatButton.configure(selectedText: `repeat`?.description)
        }).disposed(by: bag)
        viewModel.shouldGoBackAndSave = { [weak self] in
            self?.done()
        }
    }

    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        let closeBackgroundView = UIView()
        closeBackgroundView.backgroundColor = UIColor(named: "TABackground")
        view.layout(closeBackgroundView).edges()
        let backgroundGesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        closeBackgroundView.addGestureRecognizer(backgroundGesture)

        view.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        let centerYAnchor = view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let centerXAnchor = view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        centerYAnchor.priority = .init(1)
        centerXAnchor.priority = .init(1)
        centerYAnchor.isActive = true
        centerXAnchor.isActive = true
        view.layout(scrollView).trailing().leading().topSafe(13)
        view.layout(clearDoneButtons).bottom(0.01674 * UIScreen.main.bounds.height).leading().trailing().top(scrollView.anchor.bottom, 0.01674 * UIScreen.main.bounds.height)
        scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor).isActive = true
        scrollView.frameLayoutGuide.heightAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.heightAnchor).isActive = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layout(calendarView).top().centerX()
        scrollView.layout(separatorView).leading(25).trailing(25).top(calendarView.anchor.bottom, 0.02455 * UIScreen.main.bounds.height)
        let buttonsStackCenterLayout = UIView()
        scrollView.layout(buttonsStackCenterLayout).leading(25).trailing(25).top(separatorView.anchor.bottom).height(0.154017 * UIScreen.main.bounds.height)
        buttonsStackCenterLayout.layout(buttonsStack).leading().trailing().centerY()
        scrollView.layout(separatorView2).leading(25).trailing(25).top(buttonsStackCenterLayout.anchor.bottom)
        todayButton.label.snp.makeConstraints { make in
            make.firstBaseline.equalTo(tomorrowButton.label.snp.firstBaseline)
            make.firstBaseline.equalTo(nextMondayButton.label.snp.firstBaseline)
            make.firstBaseline.equalTo(eveningButton.label.snp.firstBaseline)
        }
        
        let buttonsStackCenterLayout2 = UIStackView(arrangedSubviews: [
            timeButton, reminderButton, repeatButton
        ])
        buttonsStackCenterLayout2.axis = .vertical
        buttonsStackCenterLayout2.spacing = 27
        scrollView.layout(buttonsStackCenterLayout2).leading(27).trailing(27).top(separatorView2.anchor.bottom, 0.037946 * UIScreen.main.bounds.height)
        scrollView.layout(clearButton).top(buttonsStackCenterLayout2.anchor.bottom, 0.03348 * UIScreen.main.bounds.height).leading(25).trailing(25).bottom(10).height(55)
        let scrollHeight = scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        scrollHeight.priority = .init(1)
        scrollHeight.isActive = true
    }
    @objc private func closeView() {
        self.dismiss(animated: true, completion: nil)
    }

        
    private func done() {
        self.onDone(self.viewModel.date.value.0, self.viewModel.reminder.value, self.viewModel.repeat.value)
        closeView()
    }
    
    private lazy var clearButton: NewCustomButton = {
        let button = NewCustomButton()
        button.stateBackgroundColor = .init(highlighted: UIColor(named: "TABorder")!, normal: UIColor(named: "TABorder")!.withAlphaComponent(0.4))
        button.setAttributedTitle("Clear".localizable().at.attributed { $0.foreground(color: UIColor(named: "TASubElement")!).font(Fonts.heading3) }, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(clickedClear), for: .touchUpInside)
        
        return button
    }()
    
    @objc func clickedClear() {
        viewModel.clearAll()
    }
    
    func clickedReminder() {
        let selection1Vc = Selection1Vc.reminderVc(onDone: { [weak self] in
            guard let self = self else { return }
            self.viewModel.reminderSelected($0)
        }, selected: viewModel.reminder.value)
        self.present(selection1Vc, animated: true, completion: nil)
    }
    func clickedRepeat() {
        let selection1Vc = Selection1Vc.repeatVc(onDone: { [weak self] in
            guard let self = self else { return }
            self.viewModel.repeatSelected($0)
        }, selected: viewModel.repeat.value)
        self.present(selection1Vc, animated: true, completion: nil)
    }
    func clickedTime() {
        let date = viewModel.date.value.0
        let selected = date.flatMap { (hours: $0.hour, minutes: $0.minute) }
        let timePickerVc = TimePickerVc(hours: selected?.hours ?? 0, minutes: selected?.minutes ?? 0, onDone: { [weak self] in
            guard let self = self else { return }
            self.viewModel.timeSelected(hours: $0, minutes: $1)
        })
        self.present(timePickerVc, animated: true, completion: nil)
    }
}

extension CalendarVc2 {
    
    class CalendarButton1: UIButton {
        let imageView2 = UIImageView(frame: .zero)
        let label = UILabel()
        private let onClick: () -> Void
        init(image imageName: String, text: String, isOneLine: Bool = true, imageWidth: CGFloat, onClick: @escaping () -> Void) {
            self.onClick = onClick
            super.init(frame: .zero)
            imageView2.image = UIImage(named: imageName)?.resize(toWidth: imageWidth)
            imageView2.contentMode = .bottom
            layout(imageView2).top().centerX().leading() { _, _ in .greaterThanOrEqual }.trailing() { _, _ in .lessThanOrEqual }
            label.text = text
            label.font = Fonts.heading4
            label.minimumScaleFactor = 0.84
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = isOneLine ? 1 : 2
            label.textAlignment = .center
            layout(label).top(imageView2.anchor.bottom, 9).centerX().leading() { _, _ in .greaterThanOrEqual }.trailing() { _, _ in .lessThanOrEqual }
                .bottom()
            addTarget(self, action: #selector(onClickFunc), for: .touchUpInside)
        }
        
        @objc func onClickFunc() { onClick() }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class CalendarButton2: OnClickControl {
        let imageView = UIImageView(frame: .zero)
        let label = UILabel()
        let statusLabel = UILabel()
        
        init(image imageName: String, text: String, onClick: @escaping () -> Void) {
            super.init(onClick: { if $0 { onClick() } })
            label.font = Fonts.heading3
            label.text = text
            imageView.image = UIImage(named: imageName)?.resize(toHeight: 25)
            
            layout(imageView).leading().top().bottom()
            layout(label).leading(37).centerY()
            layout(statusLabel).trailing().centerY()
            configure(selectedText: nil)
            self.pointInsideInsets = .init(top: 10, left: 0, bottom: 10, right: 0)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(selectedText: String?) {
            if let selectedText = selectedText {
                statusLabel.text = selectedText
                statusLabel.textColor = UIColor.hex("#447bfe")
            } else {
                statusLabel.text = "None".localizable()
                statusLabel.textColor = UIColor(named: "TASubElement")
            }
        }
    }
}
