//
//  CalendarVc.swift
//  TodoApp
//
//  Created by sergey on 25.11.2020.
//

import Foundation
import UIKit
import Material

final class CalendarVc: UIViewController {
    private let viewModel: CalendarVcVm
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    private lazy var calendarView: CalendarView = {
        let view = CalendarView(alreadySelectedDate: .init(), selectDate: viewModel.selectDate, datePriorities: viewModel.datePriorities)
        return view
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .hex("#DFDFDF")
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    private let separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = .hex("#DFDFDF")
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    lazy var todayButton: CalendarButton1 = {
        let button = CalendarButton1(image: "yeldoublecircle", text: "Today", onClick: viewModel.clickedToday)

        return button
    }()
    lazy var tomorrowButton: CalendarButton1 = {
        let button = CalendarButton1(image: "calendar-plussvg", text: "Tomorrow", onClick: viewModel.clickedTomorrow)
        button.imageView.tintColor = .hex("#447BFE")
        return button
    }()
    lazy var nextMondayButton: CalendarButton1 = {
        let button = CalendarButton1(image: "brightness-up", text: "Next Monday", onClick: viewModel.clickedNextMonday)
        return button
    }()
    lazy var eveningButton = CalendarButton1(image: "moon", text: "Evening", onClick: viewModel.clickedEvening)
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todayButton, tomorrowButton, nextMondayButton, eveningButton])
        stack.distribution = .fillEqually
        stack.alignment = .top
        return stack
    }()
    private let scrollView = UIScrollView()
    private lazy var clearDoneButtons = ClearDoneButtons(clear: { [unowned self] in
        print("clear")
    }, done: { [unowned self] in
        print("done")
    })
    lazy var timeButton = CalendarButton2(image: "alarm", text: "Time", onClick: clickedTime)
    lazy var reminderButton = CalendarButton2(image: "bell", text: "Reminder", onClick: clickedReminder)
    lazy var repeatButton = CalendarButton2(image: "repeat", text: "Repeat", onClick: clickedRepeat)
    
    init(viewModel: CalendarVcVm) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinding()
    }
    
    private func setupBinding() {
        viewModel.onUpdate = { [unowned self] in
            timeButton.configure(selectedText: self.viewModel.formattedTimeText)
            if let date = viewModel.taskDate.date { calendarView.jctselectDate(date) }
            reminderButton.configure(selectedText: viewModel.taskDate.reminder?.description)
            repeatButton.configure(selectedText: viewModel.taskDate.repeat?.description)
        }
    }

    private func setupViews() {
        view.backgroundColor = .hex("#F6F6F3")
        navigationItem.titleLabel.text = "Calendar"
        navigationItem.titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        view.layout(containerView).leading(13).trailing(13).topSafe(30) { _, _ in .greaterThanOrEqual }.bottomSafe(30) { _, _ in .lessThanOrEqual }
        let centerYAnchor = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let centerXAnchor = containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        centerYAnchor.priority = .init(1)
        centerXAnchor.priority = .init(1)
        centerYAnchor.isActive = true
        centerXAnchor.isActive = true
        containerView.layout(scrollView).trailing().leading().top(13)
        containerView.layout(clearDoneButtons).bottom(20).leading().trailing().top(scrollView.anchor.bottom, 20)
        scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor).isActive = true
        scrollView.frameLayoutGuide.heightAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.heightAnchor).isActive = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layout(calendarView).top().centerX()
        scrollView.layout(separatorView).leading(25).trailing(25).top(calendarView.anchor.bottom, 22)
        let buttonsStackCenterLayout = UIView()
        scrollView.layout(buttonsStackCenterLayout).leading(25).trailing(25).top(separatorView.anchor.bottom).height(138)
        buttonsStackCenterLayout.layout(buttonsStack).leading().trailing().centerY()
        scrollView.layout(separatorView2).leading(25).trailing(25).top(buttonsStackCenterLayout.anchor.bottom)
        
        let buttonsStackCenterLayout2 = UIStackView(arrangedSubviews: [
            timeButton, reminderButton, repeatButton
        ])
        buttonsStackCenterLayout2.axis = .vertical
        buttonsStackCenterLayout2.spacing = 27
        scrollView.layout(buttonsStackCenterLayout2).leading(27).trailing(27).top(separatorView2.anchor.bottom, 34).bottom()
        let scrollHeight = scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        scrollHeight.priority = .init(1)
        scrollHeight.isActive = true
    }
    
    func clickedReminder() {
        router.openReminder(onDone: { [unowned self] in self.viewModel.reminderSelected($0) }, selected: viewModel.taskDate.reminder)
    }
    func clickedRepeat() {
        router.openRepeat(onDone: { [unowned self] in self.viewModel.repeatSelected($0) }, selected: viewModel.taskDate.repeat)
    }
    func clickedTime() {
        
    }
}

extension CalendarVc {
    
    class CalendarButton1: OnClickControl {
        let imageView = UIImageView(frame: .zero)

        init(image imageName: String, text: String, onClick: @escaping () -> Void) {
            super.init(onClick: { _ in })
            imageView.image = UIImage(named: imageName)
            layout(imageView).top().centerX().leading() { _, _ in .greaterThanOrEqual }.trailing() { _, _ in .lessThanOrEqual }
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.numberOfLines = 0
            label.textAlignment = .center
            layout(label).top(imageView.anchor.bottom, 9).centerX().leading() { _, _ in .greaterThanOrEqual }.trailing() { _, _ in .lessThanOrEqual }
                .bottom()
            self.onClick = { isSelected in
                self.layer.opacity = isSelected ? 0.7 : 1
                if isSelected { onClick() }
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class CalendarButton2: UIView {
        let imageView = UIImageView(frame: .zero)
        let label = UILabel()
        let button = UIButton(type: .custom)
        private let onClick: () -> Void
        
        init(image imageName: String, text: String, onClick: @escaping () -> Void) {
            self.onClick = onClick
            super.init(frame: .zero)
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.text = text
            imageView.image = UIImage(named: imageName)?.resize(toHeight: 25)
            
            layout(imageView).leading().top().bottom()
            layout(label).leading(37).centerY()
            layout(button).trailing().centerY()
            button.addTarget(self, action: #selector(clicked), for: .touchUpInside)
            configure(selectedText: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        @objc func clicked() {
            onClick()
        }
        
        func configure(selectedText: String?) {
            if let selectedText = selectedText {
                button.setTitle(selectedText, for: .normal)
                button.setTitleColor(.hex("#447BFE"), for: .normal)
            } else {
                button.setTitle("None", for: .normal)
                button.setTitleColor(.hex("#A4A4A4"), for: .normal)
            }
        }
    }
}
