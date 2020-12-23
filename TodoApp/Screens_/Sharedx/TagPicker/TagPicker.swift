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

class Separator: UICollectionReusableView {
    static let kind = "separatorkind"
    static let reuseId = "separatorid"
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .hex("#DFDFDF")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class TagPicker: UIViewController {
    let collectionLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let separator = NSCollectionLayoutSupplementaryItem(
            layoutSize: .init(widthDimension: .absolute(199), heightDimension: .absolute(1)),
            elementKind: Separator.kind,
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
    private let bgView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedBgView))
        bgView.addGestureRecognizer(tapGesture)
        view.backgroundColor = .clear
        bgView.backgroundColor = .hex("#F6F6F3")
        bgView.layer.opacity = 0
        view.layout(bgView).edges()
        collectionView.register(TagPickerCell.self, forCellWithReuseIdentifier: "\(TagPickerCell.self)")
        collectionView.register(Separator.self, forSupplementaryViewOfKind: Separator.kind, withReuseIdentifier: Separator.reuseId)
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
        containerView.layout(collectionView).height(getCollectionViewHeight(count: items.count)).top(12).leading(10).trailing(10)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.transform = CGAffineTransform(scaleX: 1, y: 0).concatenating(.init(translationX: 0, y: containerView.frame.height / 2))
        containerView.layer.opacity = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.3) { [self] in
            containerView.transform = .identity
            containerView.layer.opacity = 1
            containerView.addShadow(offset: .init(width: 0, height: 8), opacity: 0.1, radius: 16, color: .hex("#242424"))
        }
        if shouldPurposelyAnimateViewBackgroundColor {
            UIView.animate(withDuration: 0.5) {
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
            return collectionView.dequeueReusableSupplementaryView(ofKind: Separator.kind, withReuseIdentifier: Separator.reuseId, for: ip)
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
        textField.attributedPlaceholder = "Add New Tag".at.attributed(with: attributes.foreground(color: .hex("#A4A4A4")))
        textField.delegate = self
        textField.font = .systemFont(ofSize: 18, weight: .semibold)
        return textField
    }()
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    private func properlyDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.view.layer.opacity = 0
        } completion: { _ in
            self.shouldDismiss(self)
        }
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
            finished?(.new(text))
            finished = nil
            properlyDismiss()
        }
        return false
    }
}

extension TagPicker {
    class TagPickerCell: UICollectionViewCell {
        let label: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.textColor = .hex("#242424")
            return label
        }()
        private let bgView: UIView = {
            let view = UIView()
            view.backgroundColor = .hex("#447BFE")
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
                UIView.animate(withDuration: 0.25) {
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
