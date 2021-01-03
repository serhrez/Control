//
//  PlannedVc.swift
//  TodoApp
//
//  Created by sergey on 15.12.2020.
//

import Foundation
import UIKit
import RxDataSources
import RxSwift

final class PlannedVc: UIViewController {
    private let noCalendarViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var noCalendarViewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: noCalendarViewFlowLayout)
    private let calendarViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var calendarViewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: calendarViewFlowLayout)
    private var calendarPadding: CGFloat { 13 }
    private var calendarInset: CGFloat { 9 }
    
    private lazy var calendarView: CalendarView = {
        let layout = CalendarViewLayout(availableWidth: UIScreen.main.bounds.width - calendarPadding * 2 - calendarInset * 2, cellColumns: 7, cellRows: 6)
        let view = CalendarView(layout: layout, alreadySelectedDate: .init(), selectDate: { [weak self] date in
            if let cvc = self?.calendarViewCollectionView,
               cvc.numberOfSections > 0 && cvc.numberOfItems(inSection: 0) > 0 {
                self?.calendarViewCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
            self?.viewModel.selectDayFromJct(date)
        }, datePriorities: viewModel.datePriorities)
        return view
    }()
    private lazy var calendarViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.layout(calendarView).top(6).bottom(10).leading(calendarInset).trailing(calendarInset)
        return view
    }()


    private let viewModel: PlannedVcVm = .init()
    private let bag = DisposeBag()
    private var selectedMode1 = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        view.layout(noCalendarViewCollectionView).leading(calendarPadding).trailing(calendarPadding).top().bottom()
        view.layout(calendarViewContainer).leading(calendarPadding).trailing(calendarPadding).topSafe(30)
        view.layout(calendarViewCollectionView).leading(calendarPadding).trailing(calendarPadding).top(calendarViewContainer.anchor.bottom, 7).bottom()
        setupNoCalendarCollectionView()
        noCalendarViewCollectionView.alpha = 0
        setupCalendarCollectionView()
        setupNavigationBar()
        view.layout(gradientView).bottom().leading().trailing().height(216)
    }
    
    private func setupNoCalendarCollectionView() {
        noCalendarViewCollectionView.showsVerticalScrollIndicator = false
        noCalendarViewCollectionView.backgroundColor = .clear
        noCalendarViewCollectionView.alwaysBounceVertical = true
        noCalendarViewFlowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        noCalendarViewFlowLayout.minimumLineSpacing = 7
        noCalendarViewCollectionView.delegate = self
        noCalendarViewCollectionView.register(PlannedTaskCell.self, forCellWithReuseIdentifier: PlannedTaskCell.reuseIdentifier)
        noCalendarViewCollectionView.register(PlannedVcHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlannedVcHeader.identifier)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<PlannedVcVm.AnimDateSection<PlannedVcVm.Model>> { [weak self] (dataSource, collectionView, indexPath, model) -> UICollectionViewCell in
            guard let self = self else { return .init() }
            switch model {
            case let .task(task):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlannedTaskCell.reuseIdentifier, for: indexPath) as! PlannedTaskCell
                cell.configure(text: task.name, date: task.date!.date!, priority: task.priority, tagName: task.tags.first?.name, otherTags: task.tags.count >= 2, isSelected: task.isDone, hasChecklist: !task.subtask.isEmpty, onSelected: { self.viewModel.setIsDone($0, to: task) })
                return cell
            }
        }
        dataSource.configureSupplementaryView = { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            guard let self = self else { return .init() }
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlannedVcHeader.identifier, for: indexPath) as! PlannedVcHeader
                let date = self.viewModel.noCalendarModelsUpdate.value[indexPath.section].date
                headerView.configure(date: date)
                return headerView
            default: fatalError()
            }
        }
        viewModel.noCalendarModelsUpdate
            .bind(to: noCalendarViewCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    private func setupCalendarCollectionView() {
        calendarViewCollectionView.showsVerticalScrollIndicator = false
        calendarViewCollectionView.backgroundColor = .clear
        calendarViewCollectionView.alwaysBounceVertical = true
        calendarViewFlowLayout.minimumLineSpacing = 7
        calendarViewCollectionView.delegate = self
        calendarViewCollectionView.register(PlannedTaskCell.self, forCellWithReuseIdentifier: PlannedTaskCell.reuseIdentifier)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<PlannedVcVm.Model>> { [weak self] (dataSource, collectionView, indexPath, model) -> UICollectionViewCell in
            guard let self = self else { return .init() }
            switch model {
            case let .task(task):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlannedTaskCell.reuseIdentifier, for: indexPath) as! PlannedTaskCell
                cell.configure(text: task.name, date: task.date!.date!, priority: task.priority, tagName: task.tags.first?.name, otherTags: task.tags.count >= 2, isSelected: task.isDone, hasChecklist: !task.subtask.isEmpty, onSelected: { self.viewModel.setIsDone($0, to: task) })
                return cell
            }
        }
        
        viewModel.calendarModelsUpdate
            .do(onNext: {
                if $0.isEmpty { return }
                print($0[0].items.reduce(into: "", { $0 += $1.task.name + ";" }))
            })
            .bind(to: calendarViewCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }

    func transitionToAnotherMode(onTransitioned: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5) {
            if self.selectedMode1 {
                self.noCalendarViewCollectionView.reloadData()
            } else {
                self.calendarViewCollectionView.reloadData()
            }
            self.noCalendarViewCollectionView.layer.opacity = self.selectedMode1 ? 1 : 0
            self.calendarViewCollectionView.layer.opacity = self.selectedMode1 ? 0 : 1
            self.calendarViewContainer.layer.opacity = self.selectedMode1 ? 0 : 1
        } completion: { _ in
            onTransitioned()
        }

    }

    private func setupNavigationBar() {
        navigationItem.titleLabel.text = "Planned"
        
        // Setup CustomDate
        let imageView = UIImageView(image: UIImage(named: "layout-columns"))
        let imageView2 = UIImageView(image: UIImage(named: "list-check")?.withRenderingMode(.alwaysTemplate))
        imageView2.layer.opacity = 0
        imageView.contentMode = .scaleAspectFit
        imageView2.contentMode = .scaleAspectFit
        imageView2.tintColor = .hex("#000000")
        var hasTransitioned = true
        let switchButton = CustomButtonx2(highlight: { [weak self] button, isSelected in
            guard let self = self else { return }
            let image1OnSelected: Float = self.selectedMode1 ? 1 : 0
            let image2OnSelected: Float = self.selectedMode1 ? 0 : 1
            imageView.layer.opacity = isSelected ? image1OnSelected : 1 - image1OnSelected
            imageView2.layer.opacity = isSelected ? image2OnSelected : 1 - image2OnSelected
        }, onSelected: { [weak self] in
            guard hasTransitioned else { return }
            hasTransitioned = false
            self?.selectedMode1.toggle()
            self?.transitionToAnotherMode(onTransitioned: { hasTransitioned = true })
        })
        switchButton.shouldAllowSelection = { hasTransitioned }
        switchButton.layout(imageView).center().width(24).height(24)
        switchButton.layout(imageView2).center().width(24).height(24)
        navigationItem.rightViews = [switchButton]
    }
    
    private let gradientView = GradientView()
}

extension PlannedVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch collectionView {
        case noCalendarViewCollectionView:
            return CGSize(width: collectionView.bounds.width, height: 93)
        case calendarViewCollectionView:
            return CGSize(width: 0, height: 0)
        default: fatalError()
        }
    }
}

extension PlannedVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case noCalendarViewCollectionView:
            return CGSize(width: collectionView.bounds.width, height: 62)
        case calendarViewCollectionView:
            return CGSize(width: collectionView.bounds.width, height: 62)
        default: fatalError()
        }
    }
}
 class GradientView: UIView {
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        return gradient
    }()

    init() {
        super.init(frame: .zero)
        layer.addSublayer(gradientLayer)
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        // Supporting black mode
        gradientLayer.colors = [
            UIColor(named: "TABackground")!.withAlphaComponent(0).cgColor,
            UIColor(named: "TABackground")!.withAlphaComponent(1).cgColor
        ]
    }
}

fileprivate class CustomButtonx2: UIView {
    
    var shouldAllowSelection: () -> Bool = { true }
    private let control = CustomButtonControl()
    init(highlight: @escaping (CustomButtonx2, Bool) -> Void, onSelected: @escaping () -> Void) {
        super.init(frame: .zero)
        layout(control).edges()
        var isAnimationCompleted: Bool = true
        control.shouldHighlight = { [weak self] isHighlighted in
            guard let self = self else { return }
            guard isAnimationCompleted && self.shouldAllowSelection() else { return }
            isAnimationCompleted = false
            UIView.animate(withDuration: 0.5, animations: {
                highlight(self, isHighlighted)
            }, completion: { _ in
                isAnimationCompleted = true
            })
        }
        control.onClick = {
            onSelected()
        }
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        bringSubviewToFront(control)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class CustomButtonControl: UIControl {
        
        private var animator = UIViewPropertyAnimator()
        
        var highlightedColor = UIColor.blue
        var onClick: () -> Void = { }
        var shouldHighlight: (Bool) -> Void = { _ in }
                
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupViews() {
            addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
            addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        }
        
        @objc private func touchDown() {
            shouldHighlight(true)
        }
        
        @objc private func touchUp() {
            onClick()
            shouldHighlight(false)
        }
    }

}
