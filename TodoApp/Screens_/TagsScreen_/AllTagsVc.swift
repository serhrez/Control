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
    let viewModel: AllTagsVcVm = .init()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let keyboard = Typist()
    
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
                self.view.layout(self.collectionView)
                    .bottomSafe(height - self.view.safeAreaInsets.bottom)
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

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<SectionOfCustomData> { (data, collectionView, indexPath, ds) -> UICollectionViewCell in
            switch ds {
            case let .addTag(isAddedTag):
                let addCell = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsAddTagCell.reuseIdentifier, for: indexPath) as! AllTagsAddTagCell
                addCell.configure(isAddedTag)
                return addCell
            case let .tag(tag):
                let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsTagCell.reuseIdentifier, for: indexPath) as! AllTagsTagCell
                tagCell.configure(name: tag.name, tasksCount: self.viewModel.allTasksCount(for: tag))
                tagCell.motionIdentifier = tag.id
                return tagCell
            case .addTagEnterName:
                let addTagEnterName = collectionView.dequeueReusableCell(withReuseIdentifier: AllTagsEnterNameCell.reuseIdentifier, for: indexPath) as! AllTagsEnterNameCell
                addTagEnterName.configure { (str) in
                    _ = try! RealmProvider.inMemory.realm.write {
                        RealmProvider.inMemory.realm.add(RlmTag(name: str))
                    }
                    self.viewModel.allowAdding(bool: false)
                    
                }
                return addTagEnterName
            }
        }
        viewModel.modelsq
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.delegate = self
    }
            
    func setupNavigationBar() {
        navigationItem.titleLabel.text = "Tags"
    }
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension AllTagsVc: AppNavigationRouterDelegate { }
extension AllTagsVc: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        return []
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
        case let .addTag(isAddable):
            if isAddable {
                viewModel.allowAdding()
            }
        case .addTagEnterName: break
        case let .tag(tag):
            print("tag selected: \(tag)")
            break
        }
    }
}
