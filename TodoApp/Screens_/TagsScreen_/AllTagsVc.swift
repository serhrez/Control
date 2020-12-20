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
import RealmSwift

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
    
    private func setupViews() {
        view.backgroundColor = .hex("#F6F6F3")
        setupCollectionView()
        setupNavigationBar()
        setupKeyboard()
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [unowned self] (options) in
                let height = options.endFrame.intersection(view.frame).height
                print("willChangeFrame set height: \(height)")
                if previousHeight == height { return }
                previousHeight = height
                self.collectionView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)

//                UIView.animate(withDuration: 0.5) {
//                    view.layoutSubviews()
//                }
            }
            .on(event: .willHide, do: { [unowned self] (options) in
                let height = options.endFrame.intersection(view.frame).height
                print("willHide set height: \(height)")
                if previousHeight == height { return }
                previousHeight = height
                self.collectionView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
//
//                UIView.animate(withDuration: 0.5) {
//                    view.layoutSubviews()
//                }
            })
            .start()
    }
    
    func setupCollectionView() {
        view.layout(collectionView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
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
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<AllTagsVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
             
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
                    tagCell.configure(name: tag.name, isSelected: viewModel.selectionSet.contains(tag), onSelected: { [unowned self] in self.viewModel.changeTagInSelectionSet(tag: tag, shouldBeInSet: $0) })
                    tagCell.motionIdentifier = tag.id
                    tagCell.delegate = self
                    return tagCell
                }
            case .addTagEnterName:
                let addTagEnterName = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsEnterNameCell.reuseIdentifier, for: indexPath) as! AllTagsEnterNameCell
                addTagEnterName.configure(tagCreated: self.viewModel.addTag)
                return addTagEnterName
            }
        }
        viewModel.modelsUpdate
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        viewModel.modelsUpdate
            .compactMap { $0[0].items.firstIndex(where: { $0 == .addTag }) }
            .subscribe(onNext: { [weak self] index in
                if let indexPath = self?.collectionView.indexPathsForVisibleItems.first(where: { $0.row == index }),
                   let cell = self?.collectionView.cellForItem(at: indexPath) as? AllTagsEnterNameCell {
//                    cell.becomeFirstResponder()
                }
            })
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
        navigationItem.titleLabel.text = "Tags"
    }
    
    func handleSwipeActionDeletion(action: SwipeAction, indexPath: IndexPath) {
        let tag = viewModel.models[0].items[indexPath.row]
        switch tag {
        case let .tag(tag):
            let alertVc = UIAlertController(title: "Are you sure?", message: "you really wanna delete this \(tag.name)??", preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "Hmm, not sure", style: .default))
            alertVc.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.viewModel.deleteTag(tag)
            }))
            present(alertVc, animated: true, completion: nil)
        default: return
        }
    }
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension AllTagsVc: AppNavigationRouterDelegate { }
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
        let model = viewModel.models[0].items[indexPath.row]
        guard case .tag = model else { return [] }
        let deleteAction = SwipeAction(style: .default, title: nil, handler: handleSwipeActionDeletion)
        deleteAction.backgroundColor = .hex("#EF4439")
        deleteAction.image = UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate)
        deleteAction.textColor = .white
        return [deleteAction]
    }
}

extension AllTagsVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = viewModel.models[indexPath.section].items[indexPath.row]
        switch model {
        case .addTag:
            viewModel.allowAdding()
        case .addTagEnterName: break
        case let .tag(tag):
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
