//
//  SettingsVcCollectionView.swift
//  TodoApp
//
//  Created by sergey on 28.12.2020.
//

import Foundation
import UIKit
import Material

class SettingsVcCollectionView: UIView {
    private let collectionLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let separator = NSCollectionLayoutSupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(1)),
            elementKind: UICollectionFractionalWidthSeparator.kind,
            containerAnchor: .init(edges: [.bottom], absoluteOffset: .init(x: 0, y: 1)))
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [separator])
        item.contentInsets = .init(top: 1, leading: 0, bottom: 0, trailing: 0)
        let groupHeight = NSCollectionLayoutDimension.absolute(65)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }()
    private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    private let items: [SettingsCellData]
    lazy var cellRegistration = UICollectionView.CellRegistration<SettingsCell, SettingsCellData> { cell, ip, item in
        cell.updateWithData(item)
    }
    lazy var separatorRegistration = UICollectionView.SupplementaryRegistration<UICollectionFractionalWidthSeparator>(elementKind: UICollectionFractionalWidthSeparator.kind) { separatorView, kind, indexPath in }

    init(items: [SettingsCellData]) {
        self.items = items
        super.init(frame: .zero)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        layout(collectionView).edges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsVcCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: items[indexPath.row])
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.clipsToBounds = true
        if indexPath.row == 0 { // If first
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == items.count - 1 {
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueConfiguredReusableSupplementary(using: separatorRegistration, for: indexPath)
    }
}

extension SettingsVcCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = items[indexPath.row]
        if item.active {
            item.onClick()
        }
    }
}
