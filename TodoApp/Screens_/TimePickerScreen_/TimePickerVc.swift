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
        view.backgroundColor = UIColor(named: "TAAltBackground")!
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
        clearDoneButtons = ClearDoneButtons(clear: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }, done: { [weak self] in
            guard let self = self else { return }
            onDone(self.selectedTime)
            self.navigationController?.popViewController(animated: true)
        })
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
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
}
