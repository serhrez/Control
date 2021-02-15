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
    private let projectStartedView = ProjectStartedView(mode: .freeDay)
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
        }, datePriorities: { [weak self] date in
            return self?.viewModel.datePriorities(date) ?? (false, false, false, false)
        })
        return view
    }()
    private lazy var calendarViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.addShadow(offset: .init(width: 0, height: 2), opacity: 1, radius: 16, color: UIColor(red: 0.141, green: 0.141, blue: 0.141, alpha: 0.1))

        view.layout(calendarView).top(6).bottom(10).leading(calendarInset).trailing(calendarInset)
        return view
    }()
    private var didAppear = false

    private let viewModel: PlannedVcVm = .init()
    private let bag = DisposeBag()
    private var selectedMode1 = true {
        didSet {
            rightBarButton.image = barButtonImage
            transitionToAnotherMode()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        selectedMode1 = !(!selectedMode1)
        calendarView.jctselectDate(.init())
        viewModel.selectDayFromJct(.init())
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        view.layout(projectStartedView).centerY(-100).leading(47).trailing(47)
        projectStartedViewChangeMode()
        projectStartedView.configure(mode: .noCalendarPlanned)
        view.layout(noCalendarViewCollectionView).leading(calendarPadding).trailing(calendarPadding).topSafe().bottom()
        noCalendarViewCollectionView.contentInset = .init(top: 0, left: 0, bottom: Constants.vcMinBottomPadding, right: 0)
        view.layout(calendarViewContainer).leading(calendarPadding).trailing(calendarPadding).topSafe()
        view.layout(calendarViewCollectionView).leading(calendarPadding).trailing(calendarPadding).top(calendarViewContainer.anchor.bottom, -7).bottom()
        view.bringSubviewToFront(calendarViewContainer)
        calendarViewCollectionView.contentInset = .init(top: 7 * 2, left: 0, bottom: Constants.vcMinBottomPadding, right: 0)
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
            switch model {
            case let .task(task):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlannedTaskCell.reuseIdentifier, for: indexPath) as! PlannedTaskCell
                cell.configure(text: task.name, date: task.date!.date!, priority: task.priority, tagName: task.tags.first?.name, otherTags: task.tags.count >= 2, isSelected: task.isDone, hasChecklist: !task.subtask.isEmpty, onSelected: {
                                self?.viewModel.setIsDone($0, to: task)
                })
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
            switch model {
            case let .task(task):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlannedTaskCell.reuseIdentifier, for: indexPath) as! PlannedTaskCell
                cell.configure(text: task.name, date: task.date!.date!, priority: task.priority, tagName: task.tags.first?.name, otherTags: task.tags.count >= 2, isSelected: task.isDone, hasChecklist: !task.subtask.isEmpty, onSelected: {
                            self?.viewModel.setIsDone($0, to: task)
                })
                return cell
            }
        }
        
        viewModel.calendarModelsUpdate
            .do(onNext: { [weak self] _ in
                self?.projectStartedViewChangeMode()
            })
            .bind(to: calendarViewCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    func projectStartedViewChangeMode() {
        func apply() {
            self.projectStartedView.alpha = (selectedMode1 && RealmProvider.main.realm.objects(RlmTaskDate.self).isEmpty) ? 1 : 0
        }
        if didAppear {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                apply()
            }
        } else {
            apply()
        }
    }

    func transitionToAnotherMode() {
        func apply() {
            if self.selectedMode1 {
                self.noCalendarViewCollectionView.reloadData()
            } else {
                self.calendarViewCollectionView.reloadData()
            }
            self.noCalendarViewCollectionView.layer.opacity = self.selectedMode1 ? 1 : 0
            self.calendarViewCollectionView.layer.opacity = self.selectedMode1 ? 0 : 1
            self.calendarViewContainer.layer.opacity = self.selectedMode1 ? 0 : 1
        }
        if didAppear {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                apply()
            }
        } else {
            apply()
        }
        projectStartedViewChangeMode()
    }

    private func setupNavigationBar() {
        applySharedNavigationBarAppearance()
        title = "Planned"
        rightBarButton.tintColor = UIColor(named: "TAHeading")
        navigationItem.rightBarButtonItems = [rightBarButton]
    }
    lazy var rightBarButton = UIBarButtonItem(image: barButtonImage, style: .plain, target: self, action: #selector(clickedx))
    var barButtonImage: UIImage? {
        selectedMode1 ? UIImage(named: "layout-columns") : UIImage(named: "list-check")
    }

    @objc func clickedx() {
        selectedMode1.toggle()
    }
    
    private let gradientView = GradientView()
}

extension PlannedVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let task: RlmTask
        switch collectionView {
        case noCalendarViewCollectionView:
            task = viewModel.noCalendarModelsUpdate.value[indexPath.section].items[indexPath.item].task
        case calendarViewCollectionView:
            task = viewModel.calendarModelsUpdate.value[indexPath.section].items[indexPath.item].task
        default: fatalError()
        }
        router.openTaskDetails(task)
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
