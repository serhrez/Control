//
//  TimeSelectionxView.swift
//  TodoApp
//
//  Created by sergey on 28.11.2020.
//

import Foundation
import UIKit
import Material
import PopMenu
import RxDataSources
import InfiniteLayout
import Haptica

class TimeSelectionxView: UIView {
    let collectionView = InfiniteCollectionView()
    private var initialSelected: Int
    private(set) var selected: Int
    var numberOfItems: Int
    var willMoveToNil: Bool = true
    var didFirstTimeAlreadyCentered = false
    init(maxNumber: Int, selected: Int) {
        self.numberOfItems = maxNumber
        self.initialSelected = selected
        self.selected = selected
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layout(collectionView).edges().height(192).width(72)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.infiniteDelegate = self
        collectionView.backgroundView = .none
        collectionView.backgroundColor = .clear
        collectionView.isItemPagingEnabled = true
        collectionView.register(TPVTextCell.self, forCellWithReuseIdentifier: TPVTextCell.reuseIdentifier)
        let layout = InfiniteLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = -9
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
    }
    
    func beforeDisappear() {
        guard let centered = collectionView.centeredIndexPath else { return }
        collectionView.scrollToItem(at: centered, at: .centeredVertically, animated: true)
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        willMoveToNil = newSuperview == nil
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupViews()
    }
    
    func viewDidAppear() {
        collectionView.velocityMultiplier = 500
    }
}
extension TimeSelectionxView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 72, height: 70)
    }
}

extension TimeSelectionxView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TPVTextCell.reuseIdentifier, for: indexPath) as! TPVTextCell
        let realIndexPath = self.collectionView.indexPath(from: indexPath)
        let itemText = "\(getNumberForItem(realIndexPath.item))"
        let text = itemText.count == 1 ? "0\(itemText)" : itemText
        cell.configure(text: text)
        return cell
    }
    
    func getNumberForItem(_ item: Int) -> Int {
        let r = item + initialSelected
        if numberOfItems <= r { return r - numberOfItems }
        return r
    }
    
}

extension TimeSelectionxView: InfiniteCollectionViewDelegate {
    func infiniteCollectionView(_ infiniteCollectionView: InfiniteCollectionView, didChangeCenteredIndexPath from: IndexPath?, to: IndexPath?) {
        guard let to = to else { return }
        let realIndexPath = self.collectionView.indexPath(from: to)
        selected = getNumberForItem(realIndexPath.item)
        if !willMoveToNil && didFirstTimeAlreadyCentered {
            Haptic.impact(HapticFeedbackStyle.soft).generate()
        }
        didFirstTimeAlreadyCentered = true
    }
}
