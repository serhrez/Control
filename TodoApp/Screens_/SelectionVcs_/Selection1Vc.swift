//
//  ReminderSelectionVc.swift
//  TodoApp
//
//  Created by sergey on 24.11.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

protocol Selection1VcItem {
    func description(with none: String?) -> String
}

class Selection1Vc: UIViewController {
    private let containerView = UIView()
    private let items: [Selection1VcItem]
    private var selectedIndex: Int
    private var selectionViews: [Selection1View] = []
    private let onDone: (Int) -> Void
    var noneText: String?
    
    init(title: String, items: [Selection1VcItem], selectedIndex: Int, onDone: @escaping (Int) -> Void) {
        self.items = items
        self.selectedIndex = selectedIndex
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    private func setupViews() {
        applySharedNavigationBarAppearance()
        view.backgroundColor = UIColor(named: "TABackground")
        view.layout(containerView).centerY().leadingSafe(13).trailingSafe(13)
        containerView.backgroundColor = UIColor(named: "TAAltBackground")!
        containerView.layer.cornerRadius = 16
        for i in items.enumerated() {
            let view = Selection1View(text: i.element.description(with: noneText), isSelected: i.offset == selectedIndex, isStyle2: i.offset == 0)
            view.onSelected = { [weak self] in
                guard let self = self else { return }
                self.selectItem(i.offset)
            }
            selectionViews.append(view)
        }
        let stack = UIStackView(arrangedSubviews: selectionViews)
        stack.axis = .vertical
        stack.spacing = 20
        
        containerView.layout(stack).top(30).leading(30).trailing(30)
        containerView.layout(clearDoneButtons).bottom(20).leading().trailing().top(stack.anchor.bottom, 100)
    }
    
    func selectItem(_ index: Int) {
        guard index != selectedIndex else { return }
        selectionViews[selectedIndex].setIsChecked(false)
        selectedIndex = index
        selectionViews[selectedIndex].setIsChecked(true)
    }
    
    lazy var clearDoneButtons: ClearDoneButtons = ClearDoneButtons(clear: { [weak self] in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
    }, done: { [weak self] in
        guard let self = self else { return }
        self.onDone(self.selectedIndex)
        self.navigationController?.popViewController(animated: true)
    })
    
}

extension Selection1Vc {
    static func reminderVc(onDone: @escaping (Reminder?) -> Void, selected: Reminder?) -> Selection1Vc {
        let items: [Reminder?] = [nil] + Reminder.all
        return Selection1Vc(title: "Reminder".localizable(), items: items, selectedIndex: items.firstIndex(of: selected) ?? 0) { index in
            onDone(items[index])
        }
    }
    
    static func repeatVc(onDone: @escaping (Repeat?) -> Void, selected: Repeat?) -> Selection1Vc {
        let items: [Repeat?] = [nil] + Repeat.all
        let vc = Selection1Vc(title: "Repeat".localizable(), items: items, selectedIndex: items.firstIndex(of: selected) ?? 0) { index in
            onDone(items[index])
        }
        vc.noneText = "Never".localizable()
        return vc
    }
}

extension Optional: Selection1VcItem where Wrapped: CustomStringConvertible {
    func description(with none: String?) -> String {
        return self?.description ?? none ?? "None".localizable(comment: "Selection1Vc none")
    }
}
