//
//  Selection2Vc.swift
//  TodoApp
//
//  Created by sergey on 10.04.2021.
//

import Foundation
import UIKit
import Material
import AttributedLib

protocol Selection2VcItem {
    func descriptionx(with none: String?) -> String
}

class Selection2Vc: UIViewController {
    private let items: [Selection2VcItem]
    private var selectedIndex: Int
    private var selectionViews: [Selection2View] = []
    private let onDone: (Int) -> Void
    let scrollView = UIScrollView()
    private let titleLabel = UILabel()
    var noneText: String?
    
    init(title: String, items: [Selection2VcItem], selectedIndex: Int, onDone: @escaping (Int) -> Void) {
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
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        
        view.layout(scrollView).top().leading().bottom().trailing()
        scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor).isActive = true
        
        for i in items.enumerated() {
            let view = Selection2View(text: i.element.descriptionx(with: noneText), isSelected: i.offset == selectedIndex, isStyle2: i.offset == 0)
            view.onSelected = { [weak self] in
                guard let self = self else { return }
                self.selectItem(i.offset)
            }
            selectionViews.append(view)
        }
        let stack = UIStackView(arrangedSubviews: selectionViews)
        stack.axis = .vertical
        stack.spacing = 5
        scrollView.layout(stack).top(68).leading(17).trailing(17).bottom() { _, _ in .lessThanOrEqual }
        
        scrollView.layout(clearDoneButtons).top().leading().trailing()
        
        scrollView.layout(titleLabel).top(25.5).centerX()
        titleLabel.textColor = UIColor(named: "TAHeading")!
        titleLabel.font = Fonts.heading3
        titleLabel.text = title
    }
    
    private func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func selectItem(_ index: Int) {
        guard index != selectedIndex else { return }
        selectionViews[selectedIndex].setIsChecked(false)
        selectedIndex = index
        selectionViews[selectedIndex].setIsChecked(true)
    }
    
    lazy var clearDoneButtons = ClearDoneButtons2(clear: { [weak self] in
        guard let self = self else { return }
        // Expected value like None or Never to be at the first index
        self.onDone(0)
        self.closeView()
    }, done: { [weak self] in
        guard let self = self else { return }
        self.onDone(self.selectedIndex)
        self.closeView()
    })
    
}

extension Selection2Vc {
    static func reminderVc(onDone: @escaping (Reminder?) -> Void, selected: Reminder?) -> Selection2Vc {
        let items: [Reminder?] = [nil] + Reminder.all
        return Selection2Vc(title: "Reminder".localizable(), items: items, selectedIndex: items.firstIndex(of: selected) ?? 0) { index in
            onDone(items[index])
        }
    }
    
    static func repeatVc(onDone: @escaping (Repeat?) -> Void, selected: Repeat?) -> Selection2Vc {
        let items: [Repeat?] = [nil] + Repeat.all
        let vc = Selection2Vc(title: "Repeat".localizable(), items: items, selectedIndex: items.firstIndex(of: selected) ?? 0) { index in
            onDone(items[index])
        }
        vc.noneText = "Never".localizable()
        return vc
    }
}

extension Selection2Vc: CustomFloatingPanelProtocol {
    func height() -> CGFloat {
        view.layoutSubviews()
        scrollView.layoutSubviews()
        return scrollView.contentSize.height + 68 + 15
    }
    
    func surfaceBackgroundColor() -> UIColor {
        return UIColor(named: "TAAltBackground")!
    }
}

extension Optional: Selection2VcItem where Wrapped: CustomStringConvertible {
    func descriptionx(with none: String?) -> String {
        return self?.description ?? none ?? "None".localizable(comment: "Selection1Vc none")
    }
}
