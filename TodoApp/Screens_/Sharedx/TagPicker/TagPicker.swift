//
//  TagPicker.swift
//  TodoApp
//
//  Created by sergey on 22.12.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

final class TagPicker: UIViewController {
    let collectionLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let separator = NSCollectionLayoutSupplementaryItem(
            layoutSize: .init(widthDimension: .absolute(199), heightDimension: .absolute(1)),
            elementKind: UICollectionSeparator.kind,
            containerAnchor: .init(edges: [.bottom], absoluteOffset: .init(x: 0, y: 9.5)))
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [separator])
        item.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)
        let groupHeight = NSCollectionLayoutDimension.absolute(54)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        return UICollectionViewCompositionalLayout(section: section)
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private lazy var dataSource = makeDataSource()
    private let items: [String]
    private var finished: ((Output) -> Void)?
    private var shouldDismiss: (TagPicker) -> Void
    private let viewSourceFrame: CGRect
    private let shouldPurposelyAnimateViewBackgroundColor: Bool
    private let bgView = UIView()
    private var didCompleteAnim = false
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    
    init(viewSource: UIView, items: [String], shouldPurposelyAnimateViewBackgroundColor: Bool = true, shouldDismiss: @escaping (TagPicker) -> Void, finished: @escaping (Output) -> Void) {
        self.items = items
        self.shouldDismiss = shouldDismiss
        self.finished = finished
        self.shouldPurposelyAnimateViewBackgroundColor = shouldPurposelyAnimateViewBackgroundColor
        viewSourceFrame = viewSource.convert(viewSource.bounds, to: nil)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedBgView))
        bgView.addGestureRecognizer(tapGesture)
        view.backgroundColor = .clear
        bgView.backgroundColor = UIColor(named: "TABackground")
        bgView.layer.opacity = 0
        view.layout(bgView).edges()
        collectionView.register(TagPickerCell.self, forCellWithReuseIdentifier: "\(TagPickerCell.self)")
        collectionView.register(UICollectionSeparator.self, forSupplementaryViewOfKind: UICollectionSeparator.kind, withReuseIdentifier: UICollectionSeparator.reuseId)
        collectionView.showsVerticalScrollIndicator = false
        view.layout(containerView).width(239).bottom(view.frame.height - viewSourceFrame.maxY)
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(-(view.frame.width / 2) + viewSourceFrame.center.x).priority(999)
            make.leading.greaterThanOrEqualTo(30)
            make.trailing.lessThanOrEqualTo(30)
        }
        if items.count <= maxTagsShown {
            collectionView.isScrollEnabled = false
        }
        containerView.layout(collectionView).height(getCollectionViewHeight(count: items.count)).top(items.isEmpty ? 0 : 12).leading(10).trailing(10)
        containerView.layout(externalCell).top(collectionView.anchor.bottom, 9).leading(collectionView).trailing(collectionView).bottom(12)
        applySnapshot(animatingDifferences: false)
    }
    
    @objc private func tappedBgView() {
        properlyDismiss()
    }
    
    private let maxTagsShown = 3
    
    func getCollectionViewHeight(count: Int) -> CGFloat {
        let calcCount: Int = min(count, maxTagsShown)
        let height = max(CGFloat((44 + 20) * calcCount - 10), 0)
        return count > maxTagsShown ? height + 34 : height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.layer.opacity = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.setAnchorPoint(.init(x: 0.5, y: 1))
        containerView.transform = CGAffineTransform(scaleX: 1, y: 0.05)

        UIView.animate(withDuration: Constants.animationDefaultDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) { [self] in
            containerView.transform = .identity
            containerView.layer.opacity = 1
            containerView.addShadow(offset: .init(width: 0, height: 8), opacity: 0.1, radius: 16, color: UIColor(named: "TABackground")!)
        } completion: { _ in
            self.containerView.setAnchorPoint(.init(x: 0.5, y: 0.5))
            self.didCompleteAnim = true
        }
        
        if shouldPurposelyAnimateViewBackgroundColor {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                self.bgView.layer.opacity = 0.5
            }
        }
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, ip, name) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TagPickerCell.self)", for: ip) as? TagPickerCell
            cell?.configure(text: name)
            return cell
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, ip -> UICollectionReusableView? in
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionSeparator.kind, withReuseIdentifier: UICollectionSeparator.reuseId, for: ip)
        }
        return dataSource
    }
    lazy var externalCell: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        view.layout(plusExternalCell).leading(20).centerY()
        view.layout(textFieldExternalCell).leading(54).centerY().trailing().trailing(22)
        return view
    }()
    let plusExternalCell: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plus"))
        imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        return imageView
    }()
    lazy var textFieldExternalCell: UITextField = {
        let textField = UITextField()
        let attributes = Attributes().font(.systemFont(ofSize: 18, weight: .semibold))
        textField.attributedPlaceholder = "Add New Tag".at.attributed(with: attributes.foreground(color: UIColor(named: "TASubElement")!))
        textField.delegate = self
        textField.font = .systemFont(ofSize: 18, weight: .semibold)
        return textField
    }()
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")!
        view.layer.cornerRadius = 16
        return view
    }()
    
    private func properlyDismiss() {
        UIView.animate(withDuration: Constants.animationDefaultDuration) {
            self.view.layer.opacity = 0
        } completion: { _ in
            self.shouldDismiss(self)
        }
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return textFieldExternalCell.becomeFirstResponder()
    }
    
    enum Output {
        case existed(String)
        case new(String)
    }
}
extension TagPicker: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        finished?(.existed(item))
        finished = nil
        properlyDismiss()
    }
}

extension TagPicker: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text,
           !text.isEmpty {
            guard RealmProvider.main.realm.objects(RlmTag.self).count < Constants.maximumTags else {
                router.openPremiumFeatures(notification: .tagsLimit)
                return false
            }
            finished?(.new(text))
            finished = nil
            properlyDismiss()
        }
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return didCompleteAnim
    }
}

extension TagPicker {
    class TagPickerCell: UICollectionViewCell {
        let label: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.textColor = UIColor(named: "TAHeading")!
            return label
        }()
        private let bgView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "TASubElement")
            view.layer.opacity = 0
            view.layer.cornerRadius = 8
            return view
        }()
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.layout(bgView).edges()
            contentView.layout(label).centerY().leading(22).trailing(22)
        }
        func configure(text: String) {
            label.text = text
        }
        
        override var isHighlighted: Bool {
            didSet {
                UIView.animate(withDuration: Constants.animationDefaultDuration) {
                    self.bgView.layer.opacity = self.isHighlighted ? 0.1 : 0
                }
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension TagPicker {
    enum Section {
        case main
    }
}
