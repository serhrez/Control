//
//  IconPickerFullVc.swift
//  TodoApp
//
//  Created by sergey on 24.12.2020.
//

import Foundation
import UIKit
import Material
import Typist
import AttributedLib

class IconPickerEmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "ipecell"
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout(label).center()
        label.font = .systemFont(ofSize: frame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(emoji: String) {
        label.text = emoji
    }
}

class IconPickerEmojiHeader: UICollectionReusableView {
    static let reuseIdentifier = "ipeheaderidentifier"
    
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout(label).centerY().leading(11).trailing(11)
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .hex("#242424")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(name: String) {
        label.text = name
    }
}

final class IconPickerFullVc: UIViewController {
    let collectionLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.16), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 11, bottom: 11, trailing: 11)
                
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.16))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .absolute(55))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
//    private lazy var dataSource: DataSource = {
//        let dataSource = DataSource(collectionView: collectionView) { (collectionView, ip, emoji) -> UICollectionViewCell? in
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconPickerEmojiCell.reuseIdentifier, for: ip) as! IconPickerEmojiCell
//            cell.configure(emoji: emoji)
//            return cell
//        }
//        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, ip -> UICollectionReusableView? in
//            guard let self = self else { return nil }
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: IconPickerEmojiHeader.reuseIdentifier, for: ip) as! IconPickerEmojiHeader
////            let headerString = self.items.filter { !$0.1.isEmpty }[ip.section].0.viewString
////            header.configure(name: headerString)
//            return header
//        }
//        return dataSource
//    }()
    var items: [ItemWithSection] = IconPickerFullVc.allEmojis {
        didSet {
            DispatchQueue.main.async {
            self.applyDifference()
            }
        }
    }
    typealias ItemWithSection = (EmojiiSection, [Emojii])
    typealias DataSource = UICollectionViewDiffableDataSource<EmojiiSection, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<EmojiiSection, String>

    private let containerView = UIView()
    private let keyboard = Typist()
    private let onSelected: (String) -> Void
    
    init(onSelected: @escaping (String) -> Void) {
        self.onSelected = onSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applySharedNavigationBarAppearance()
        setupSearchBar()
        setupKeyboard()
        view.backgroundColor = .hex("#F6F6F3")
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        collectionView.contentInset = .init(top: 17, left: 0, bottom: 0, right: 0)
        collectionView.register(IconPickerEmojiCell.self, forCellWithReuseIdentifier: IconPickerEmojiCell.reuseIdentifier)
        collectionView.register(IconPickerEmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: IconPickerEmojiHeader.reuseIdentifier)
        collectionView.backgroundColor = .clear
        view.layout(containerView).topSafe(15).leading(13).trailing(13).bottom()
        containerView.layout(collectionView).top().leading(17).trailing(17).bottom()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchBar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.72, height: 44))
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = .hex("#ffffff")
        
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClicked))
        cancelButton.tintColor = UIColor.hex("#447BFE")
        cancelButton.setTitleTextAttributes(Attributes().font(.systemFont(ofSize: 16, weight: .bold)).dictionary, for: .normal)
        navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    private func setupKeyboard() {
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.intersection(containerView.frame).height
                UIView.animate(withDuration: 0) {
                    self.collectionView.contentInset = .init(top: 17, left: 0, bottom: height, right: 0)
                    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
//                    self.view.layout(self.collectionView).bottomSafe(height - self.view.safeAreaInsets.bottom)
//                    self.view.layoutIfNeeded()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(containerView.frame).height
                UIView.animate(withDuration: 0) {
                    self.collectionView.contentInset = .init(top: 17, left: 0, bottom: height, right: 0)
                    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
//                    self.view.layout(self.collectionView).bottomSafe(height - self.view.safeAreaInsets.bottom)
//                    self.view.layoutIfNeeded()
                }
            }
            .start()
    }

    @objc func cancelClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    func applyDifference() {
        self.collectionView.reloadData()
    }
//    func applyDifference(animatingDifferences: Bool = true) {
//        var snapshot = Snapshot()
//        let filtered = items.filter { !$0.1.isEmpty }
//        snapshot.appendSections(filtered.map { $0.0 })
//        for section in filtered {
//            snapshot.appendItems(section.1.map { $0.emoji }, toSection: section.0)
//        }
//        DispatchQueue.global(qos: .userInteractive).async { [self] in
//            dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
//        }
//    }
    
//    func applySnapshot(animatingDifferences: Bool = true) {
//        var snapshot = Snapshot()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(items)
//        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
//    }
    var didDisappear: () -> Void = { }
    deinit { didDisappear() }

}

extension IconPickerFullVc: AppNavigationRouterDelegate { }

extension IconPickerFullVc: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconPickerEmojiCell.reuseIdentifier, for: indexPath) as! IconPickerEmojiCell
        let item = self.items[indexPath.section].1[indexPath.row]
        cell.configure(emoji: item.emoji)
        return cell
    }
//    func collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items[section].1.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: IconPickerEmojiHeader.reuseIdentifier, for: indexPath) as! IconPickerEmojiHeader
        let headerString = self.items.filter { !$0.1.isEmpty }[indexPath.section].0.viewString
        header.configure(name: headerString)
        return header
    }
}

extension IconPickerFullVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.items[indexPath.section].1[indexPath.row]
        onSelected(item.emoji)
        navigationController?.popViewController(animated: true)
    }
}

extension IconPickerFullVc: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { self.items = IconPickerFullVc.allEmojis; return }
        var newItems: [ItemWithSection] = []
        
        for emoj in IconPickerFullVc.allEmojis {
            if checkSimilarity(str1: emoj.0.viewString, str2: searchText) {
                newItems.append(emoj)
            } else {
                let newEmojis: [Emojii] = emoj.1.filter { checkSimilarity(str1: $0.description, str2: searchText) }
                newItems.append((emoj.0, newEmojis))
            }
        }
        items = newItems.filter { !$0.1.isEmpty }

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func checkSimilarity(str1: String, str2: String) -> Bool {
        return str1.contains(str2) || str2.contains(str1)
    }
}

extension IconPickerFullVc: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        }
        return true
    }
    
}