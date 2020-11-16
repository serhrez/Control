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
    private let viewModel: AllTagsVcVm = .init()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let keyboard = Typist()
    
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
        keyboard
            .on(event: .willChangeFrame) { [unowned self] (options) in
                let height = options.endFrame.height
                UIView.animate(withDuration: 0) {
                    self.view.layout(self.collectionView)
                        .bottomSafe(height - self.view.safeAreaInsets.bottom)
                    self.view.layoutIfNeeded()
                }
            }
            .on(event: .willHide, do: { (options) in
                self.view.layout(self.collectionView).bottomSafe()
            })
            .start()
    }
    
    func setupCollectionView() {
        view.layout(collectionView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(AllTagsTagCell.self, forCellWithReuseIdentifier: AllTagsTagCell.reuseIdentifier)
        collectionView.register(AllTagsAddTagCell.self, forCellWithReuseIdentifier: AllTagsAddTagCell.reuseIdentifier)
        collectionView.register(AllTagsEnterNameCell.self, forCellWithReuseIdentifier: AllTagsEnterNameCell.reuseIdentifier)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<AllTagsVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            
            switch model {
            case .addTag:
                let addCell = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsAddTagCell.reuseIdentifier, for: indexPath) as! AllTagsAddTagCell
                return addCell
            case let .tag(tag):
                let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsTagCell.reuseIdentifier, for: indexPath) as! AllTagsTagCell
                tagCell.configure(name: tag.name, tasksCount: self.viewModel.allTasksCount(for: tag))
                tagCell.motionIdentifier = tag.id
                tagCell.delegate = self
                return tagCell
            case .addTagEnterName:
                let addTagEnterName = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsEnterNameCell.reuseIdentifier, for: indexPath) as! AllTagsEnterNameCell
                addTagEnterName.configure(tagCreated: self.viewModel.addTag)
                return addTagEnterName
            }
        }
        viewModel.modelsUpdate
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.delegate = self
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
            alertVc.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.viewModel.deleteTag(tag)
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
        deleteAction.image = UIImage(named: "trash")
        return [deleteAction]
    }
}

extension AllTagsVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: 55)
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
            print("tag selected: \(tag)")
            break
        }
    }
}
