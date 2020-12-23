//
//  TimePickerVc.swift
//  TodoApp
//
//  Created by sergey on 28.11.2020.
//

import Foundation
import UIKit
import Material

class TimePickerVc: UIViewController {
    private let timeSelectionHoursView: TimeSelectionxView
    private let timeSelectionMinutesView: TimeSelectionxView
    var selectedTime: (hours: Int, minutes: Int) {
        (hours: timeSelectionHoursView.selected, minutes: timeSelectionMinutesView.selected)
    }
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    private let incontainerCenter: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let twoDots: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 58, weight: .semibold)
        return label
    }()
    private var clearDoneButtons: ClearDoneButtons!
    
    init(hours: Int, minutes: Int, onDone: @escaping ((hours: Int, minutes: Int)) -> Void) {
        self.timeSelectionHoursView = TimeSelectionxView(maxNumber: 24, selected: hours)
        self.timeSelectionMinutesView = TimeSelectionxView(maxNumber: 60, selected: minutes)
        super.init(nibName: nil, bundle: nil)
        clearDoneButtons = ClearDoneButtons(clear: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }, done: { [unowned self] in
            onDone(self.selectedTime)
            self.navigationController?.popViewController(animated: true)
        })
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        view.backgroundColor = .hex("#F6F6F3")
        view.layout(containerView).leadingSafe(13).trailingSafe(13).centerY()
        containerView.layout(incontainerCenter).top(53).centerX().width(containerView.anchor.width).multiply(0.63)
        incontainerCenter.layout(timeSelectionHoursView).leading().top().bottom()
        incontainerCenter.layout(twoDots).center()
        incontainerCenter.layout(timeSelectionMinutesView).trailing().top().bottom()
        containerView.layout(clearDoneButtons).top(incontainerCenter.anchor.bottom, 63).bottom(20).leading(20).trailing(20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        [timeSelectionHoursView, timeSelectionMinutesView].forEach { $0.viewDidAppear() }
    }
    deinit {
        didDisappear()
    }
    var didDisappear: () -> Void = { }
}
extension TimePickerVc: AppNavigationRouterDelegate { }
