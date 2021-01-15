//
//  IconPicker.swift
//  TodoApp
//
//  Created by sergey on 12.12.2020.
//

import Foundation
import UIKit

final class IconPicker: UIViewController {
    private var itemWidthHeight: CGFloat { 48 }
    private var interitemSpace: CGFloat { 32 }
    private var collectionLineSpacing: CGFloat { 23 }
    private var leftPaddingCollection: CGFloat { 26 }
    private var indicatorRightPaddingToContainer: CGFloat { 10 }
    private var collectionRightPaddingToIndicator: CGFloat { 14 }
    private var topBottomPaddingCollection: CGFloat { 25 }
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: itemWidthHeight, height: itemWidthHeight)
        layout.minimumInteritemSpacing = interitemSpace
        layout.minimumLineSpacing = collectionLineSpacing
        return layout
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: collectionRightPaddingToIndicator)
        return collectionView
    }()
    private lazy var whiteContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(named: "TAAltBackground")!
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        let containerSize = getCollectionSize(rows: 4, columns: 3)
        container.widthAnchor.constraint(equalToConstant: containerSize.width).isActive = true
        container.heightAnchor.constraint(equalToConstant: containerSize.height).isActive = true
        container.layout(collectionView).edges(
            top: topBottomPaddingCollection, left: leftPaddingCollection,
            bottom: topBottomPaddingCollection, right: indicatorRightPaddingToContainer)
        return container
    }()
    private lazy var onClickBackground = OnClickControl(
        onClick: { [weak self] in
            guard let self = self else { return }
            if !$0 {
                self.dismiss(animated: true, completion: nil)
            }
        })
    private let sourceViewFrame: CGRect
    private var selectedIndexPath: IndexPath = .init(row: 0, section: 0) {
        didSet {
            onSelection(symbols[selectedIndexPath.row])
        }
    }
    private let onSelection: (Icon) -> Void
    
    init(viewSource: UIView, selected: Icon, onSelection: @escaping (Icon) -> Void) {
        self.onSelection = onSelection
        sourceViewFrame = viewSource.frame//.convert(viewSource.bounds, to: nil)
        super.init(nibName: nil, bundle: nil)
        selectedIndexPath = symbols.firstIndex(of: selected).flatMap { IndexPath(row: $0, section: 0) } ?? .init(row: -1, section: 0)

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TABackground")!.withAlphaComponent(0.8)
        setupViews()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.flashScrollIndicators()
    }
    func setupViews() {
        view.layout(onClickBackground).edges()
        view.layout(whiteContainer).leading(sourceViewFrame.origin.x).top(sourceViewFrame.origin.y)
    }
    
    func setupCollectionView() {
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 10)
        collectionView.register(IconColCell.self, forCellWithReuseIdentifier: IconColCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    func getCollectionSize(rows: Int, columns: Int) -> CGSize {
        if rows == 0 || columns == 0 { return .zero }
        let totalWidth = sourceViewFrame.origin.x + leftPaddingCollection + indicatorRightPaddingToContainer + collectionRightPaddingToIndicator + (itemWidthHeight * CGFloat(columns)) + (interitemSpace * CGFloat(columns - 1))
        if totalWidth + 30 > UIScreen.main.bounds.width {
            return getCollectionSize(rows: rows, columns: columns - 1)
        }
        let totalHeight = sourceViewFrame.origin.y + topBottomPaddingCollection * 2 + (itemWidthHeight * CGFloat(rows)) + (collectionLineSpacing * CGFloat(rows - 1))
        if totalHeight + 30 > UIScreen.main.bounds.height {
            return getCollectionSize(rows: rows - 1, columns: columns)
        }
        return .init(width: totalWidth, height: totalHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IconPicker: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == selectedIndexPath { return }
        if let prevCell = getCell(at: selectedIndexPath) {
            prevCell.configure(isSelected: false)
        }
        selectedIndexPath = indexPath
        let newCell = getCell(at: selectedIndexPath)
        newCell?.configure(isSelected: true)
    }
}

extension IconPicker: UICollectionViewDataSource {
    func getCell(at indexPath: IndexPath) -> IconColCell? {
        if collectionView.indexPathsForVisibleItems.firstIndex(of: indexPath) != nil {
            return collectionView.cellForItem(at: indexPath) as? IconColCell
        }
        return nil
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconColCell.identifier, for: indexPath) as! IconColCell
        cell.initialConfigure(icon: symbols[indexPath.row], isSelected: selectedIndexPath == indexPath)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        symbols.count
    }
}

extension IconPicker {
    private var symbols: [Icon] {
        let x: [Icon] = [.text("🚒"), .text("🎥")]
        var res: [Icon] = []
        for _ in 1...20 {
            res += x
        }
        return res
    }
}
