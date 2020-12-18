//
//  UpdateDiffRx.swift
//  TodoApp
//
//  Created by sergey on 18.12.2020.
//

import Foundation
import RxSwift
import DeepDiff
import RxCocoa

protocol UpdateDiffModel: Hashable {
    var diffId: String { get }
    var updateId: String { get }
}

fileprivate class InternalDiffModel<Model: UpdateDiffModel>: DiffAware {
    static func compareContent(_ a: InternalDiffModel, _ b: InternalDiffModel) -> Bool {
        return a.diffId == b.diffId
    }
    var diffId: String { xpmodel2.diffId }
    var xpmodel2: Model
    
    init(_ xpmodel2: Model) {
        self.xpmodel2 = xpmodel2
    }
}

class UpdateDiffDataSource<Model: UpdateDiffModel>: NSObject, UICollectionViewDataSource {
    typealias CellForItemFunc = (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ model: Model) -> UICollectionViewCell
    private var items: [Model] = [] {
        didSet {
            itemsSet = Set(items)
        }
    }
    
    private var itemsSet: Set<Model> = []
    private var cellForItemAt: CellForItemFunc
    private let bag = DisposeBag()
    let modelBinding = PublishSubject<[Model]>()
    private weak var collectionView: UICollectionView?
    var updateCell: (UICollectionViewCell, IndexPath, Model) -> Void = { _, _, _ in }
    
    init(collectionView: UICollectionView?, cellForItemAt: @escaping CellForItemFunc) {
        self.collectionView = collectionView
        self.cellForItemAt = cellForItemAt
        super.init()
        modelBinding
            .distinctUntilChanged { diff1, diff2 in
                zip(diff1, diff2).allSatisfy { ($0.diffId == $1.diffId) && ($0.updateId == $1.updateId) }
            }
            .subscribe(onNext: newModelCome)
            .disposed(by: bag)
    }
    
    private func newModelCome(newItems: [Model]) {
        triggerUpdate(newItems: newItems)
        let internalOldItems = items.map { InternalDiffModel($0) }
        let internalNewItems = newItems.map { InternalDiffModel($0) }
        let changes = diff(old: internalOldItems, new: internalNewItems)
        
        collectionView?.reload(changes: changes, section: 0, updateData: {
            self.items = internalNewItems.map { $0.xpmodel2 }
        }, completion: nil)
    }
    
    private func triggerUpdate(newItems: [Model]) {
        var shouldBeUpdated: [String: Model] = [:]
        for newItem in newItems {
            if let oldItem = itemsSet.first(where: { $0.diffId == newItem.diffId }),
               oldItem.updateId != newItem.updateId {
                shouldBeUpdated[oldItem.diffId] = newItem
            }
        }
        var shouldBeUpdatedip: [IndexPath: Model] = [:]
        for (diffId, model) in shouldBeUpdated {
            if let itemIndex = items.firstIndex(where: { $0.diffId == diffId }) {
                items[itemIndex] = model
                shouldBeUpdatedip[IndexPath(row: itemIndex, section: 0)] = model
            }
        }
        shouldBeUpdatedip.filter { collectionView?.indexPathsForVisibleItems.contains($0.key) ?? false }
            .forEach { (ip, value) in
                if let cell = collectionView?.cellForItem(at: ip) {
                    updateCell(cell, ip, value)
                }
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cellForItemAt(collectionView, indexPath, items[indexPath.row])
    }
}
