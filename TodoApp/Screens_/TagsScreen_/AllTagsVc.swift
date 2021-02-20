//
//  AllTagsVc.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import Material
import SwipeCellKit
import RxDataSources
import RxSwift
import RxCocoa
import Typist

class AllTagsVc: UIViewController {
    private let bag = DisposeBag()
    private let viewModel: AllTagsVcVm
    private let collectionLayout: UICollectionViewLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        var item = NSCollectionLayoutItem(layoutSize: size)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }()
    private var isVisible = false
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    private let keyboard = Typist()
    private let mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        self.viewModel = .init(mode: mode)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews() 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible = false
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        setupCollectionView()
        setupNavigationBar()
        setupKeyboard()
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [weak self] (options) in
                guard let self = self else { return }
                guard self.isVisible else { return }
                let height = options.endFrame.intersection(self.view.frame).height
                print("willChangeFrame set height: \(height)")
                if previousHeight == height { return }
                previousHeight = height
                self.collectionView.contentInset = .init(top: 0, left: 0, bottom: max(height, Constants.vcMinBottomPadding + 10), right: 0)
            }
            .on(event: .willHide, do: { [weak self] (options) in
                guard let self = self else { return }
                guard self.isVisible else { return }
                let height = options.endFrame.intersection(self.view.frame).height
                print("willHide set height: \(height)")
                if previousHeight == height { return }
                previousHeight = height
                self.collectionView.contentInset = .init(top: 0, left: 0, bottom: max(height, Constants.vcMinBottomPadding + 10), right: 0)
            })
            .start()
    }
    
    func setupCollectionView() {
        view.layout(collectionView).topSafe().bottom().leadingSafe(13).trailingSafe(13)
        collectionView.contentInset = .init(top: 0, left: 0, bottom: Constants.vcMinBottomPadding + 10, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        switch mode {
        case .show:
            collectionView.register(AllTagsTagCell.self, forCellWithReuseIdentifier: AllTagsTagCell.reuseIdentifier)
        case .selection:
            collectionView.register(AllTagsSelectionTagCell.self, forCellWithReuseIdentifier: AllTagsSelectionTagCell.reuseIdentifier)
        }
        collectionView.register(AllTagsAddTagCell.self, forCellWithReuseIdentifier: AllTagsAddTagCell.reuseIdentifier)
        collectionView.register(AllTagsEnterNameCell.self, forCellWithReuseIdentifier: AllTagsEnterNameCell.reuseIdentifier)
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<AllTagsVcVm.Model>> { [weak self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            guard let self = self else { return .init() }
            switch model {
            case .addTag:
                let addCell = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsAddTagCell.reuseIdentifier, for: indexPath) as! AllTagsAddTagCell
                return addCell
            case let .tag(tag):
                switch self.mode {
                case .show:
                    let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsTagCell.reuseIdentifier, for: indexPath) as! AllTagsTagCell
                    tagCell.configure(name: tag.name, tasksCount: self.viewModel.allTasksCount(for: tag))
                    tagCell.motionIdentifier = tag.id
                    tagCell.delegate = self
                    return tagCell
                case .selection:
                    let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsSelectionTagCell.reuseIdentifier, for: indexPath) as! AllTagsSelectionTagCell
                    tagCell.configure(name: tag.name, isSelected: self.viewModel.selectionSet.contains(tag), onSelected: { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.changeTagInSelectionSet(tag: tag, shouldBeInSet: $0)
                    })
                    tagCell.motionIdentifier = tag.id
                    tagCell.delegate = self
                    return tagCell
                }
            case .addTagEnterName:
                let addTagEnterName = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsEnterNameCell.reuseIdentifier, for: indexPath) as! AllTagsEnterNameCell
                addTagEnterName.configure(tagCreated: self.viewModel.addTag, shouldClose: { [weak self] in
                    self?.viewModel.addTagClosedWithoutAdding()
                })
                return addTagEnterName
            }
        }
        viewModel.modelsUpdate
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.delegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        switch mode {
        case .show: break
        case let .selection(selected: _, selection):
            selection(Array(viewModel.selectionSet))
        }
    }
            
    func setupNavigationBar() {
        applySharedNavigationBarAppearance()
        title = "Tags".localizable()
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, indexPath: IndexPath) {
        let tag = viewModel.models[0].items[indexPath.row]
        switch tag {
        case let .tag(tag):
            let alertVc = UIAlertController(title: "Delete Tag".localizable(), message: "Tag".localizable() + " '\(tag.name)' " + "will be removed from all your tasks".localizable(), preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "Cancel".localizable(), style: .default))
            alertVc.addAction(UIAlertAction(title: "Delete".localizable(), style: .destructive, handler: { [weak self] _ in
                self?.viewModel.deleteTag(tag)
            }))
            present(alertVc, animated: true, completion: nil)
        default: return
        }
    }
}

extension AllTagsVc: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        options.minimumButtonWidth = 87
        options.maximumButtonWidth = 200
        options.expansionStyle = .selection
        return options
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let model = viewModel.models[0].items[indexPath.row]
        guard case .tag = model else { return [] }
        let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionDeletion)
        deleteAction.backgroundColor = .hex("#EF4439")
        deleteAction.image = UIImage(named: "trash")?.withTintColor(UIColor(hex: "#FFFFFF")!, renderingMode: .alwaysTemplate)
        return [deleteAction]
    }
}

extension AllTagsVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = viewModel.models[indexPath.section].items[indexPath.row]
        switch model {
        case .addTag:
            guard KeychainWrapper.shared.isPremium ||  RealmProvider.main.realm.objects(RlmTag.self).count <= Constants.maximumTags else {
                router.openPremiumFeatures(notification: .tagsLimit)
                return
            }
            viewModel.allowAdding()
        case .addTagEnterName: break
        case let .tag(tag):
            switch mode {
            case .selection: break
            case .show:
                let tasksNotEmpty = !RealmProvider.main.realm.objects(RlmTask.self).filter { $0.tags.contains(tag) }.isEmpty
                if tasksNotEmpty {
                    router.openTagDetails(tag: tag)
                }
            }
            break
        }
    }
}

extension AllTagsVc {
    enum Mode {
        case show
        case selection(selected: [RlmTag], ([RlmTag]) -> Void)
    }
}
