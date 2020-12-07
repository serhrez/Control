//
//  SubtaskCell.swift
//  TodoApp
//
//  Created by sergey on 19.11.2020.
//

import Foundation
import UIKit
import SwipeCellKit
import SnapKit
import SwiftDate
import Material
import ResizingTokenField

final class TaskCell: UICollectionViewCell {
    static let reuseIdentifier = "taskcell"
    static let textFieldFont = UIFont.systemFont(ofSize: 20, weight: .regular)
    static let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
    private let checkboxView = CheckboxView()
    private let textField: UITextField = {
        let textField = UITextField()
        textField.layoutEdgeInsets = .zero
        textField.attributedPlaceholder = "New Checklist...".at.attributed { attr in
            attr.font(textFieldFont).foreground(color: .hex("#A4A4A4"))
        }
        textField.textColor = .hex("#242424")
        textField.font = textFieldFont
        return textField
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = dateLabelFont
        label.textColor = .hex("#A4A4A4")
        label.text = Int.random(in: 1...2) == 1 ? "30 December 14:35" : ""
        return label
    }()
    private let scrollView = UIView()
    private let tokenField = ResizingTokenField()
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plus"))
        return imageView
    }()
    var tokenFieldHeight: CGFloat = 0
    var onDeleteTag: () -> Void = { }
    var addToken: (String) -> Void = { _ in }

    var onSelected: (() -> Void)? {
        get { checkboxView.onSelected }
        set { checkboxView.onSelected = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configure(text: String?, date: Date?, priority: Priority, isSelected: Bool, tags: [RlmTag]) {
        if let text = text { self.textField.text = text }
        textField.text = priority.rawValue
        dateLabel.text = date?.toFormat("yyyy MMM HH:mm")
        checkboxView.configure(priority: priority)
        checkboxView.configure(isChecked: isSelected)
        
        let tokens = tags.map { ResizingToken(title: $0.name) }
        tokenField.removeAll()
        tokenField.append(tokens: tokens)
   }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        tokenField.layoutSubviews()
        tokenField.collectionView.layoutSubviews()
        let dateLabelHeight: CGFloat = !(dateLabel.text?.isEmpty ?? true) ? dateLabel.font.lineHeight : 0
        let height = (textField.font?.lineHeight ?? 0) + dateLabelHeight + tokenFieldHeight + 2
        return .init(width: targetSize.width, height: height)
    }

    func setupViews() {
        contentView.layout(checkboxView).top(2).leading()
        contentView.layout(textField).top().leading(32).trailing()
        contentView.layout(dateLabel).leading(textField.anchor.leading).trailing()
            .top(textField.anchor.bottom)
        contentView.layout(tokenField).top(dateLabel.anchor.bottom).leading(textField.anchor.leading).trailing()//.bottom()
        setupTokenField()
    }
    
    
    private func setupTokenField() {
        tokenField.delegate = self
        tokenField.itemSpacing = 4
        tokenField.allowDeletionTags = true
        tokenField.hideLabel(animated: false)
        tokenField.font = .systemFont(ofSize: 15, weight: .semibold)
        tokenField.preferredTextFieldReturnKeyType = .done
        tokenField.contentInsets = .zero
        tokenField.textFieldAttributedPlaceholder = "Tag".at.attributed { attr in
            attr.foreground(color: UIColor.hex("#00CE15").withAlphaComponent(0.3)).font(.systemFont(ofSize: 15, weight: .semibold))
        }
        tokenField.isHidden = false
        tokenField.textFieldMinWidth = 52.5
        tokenField.shownState = .textField
        tokenField.textFieldDelegate = self
        tokenField.contentInsets = .init(top: 2, left: 0, bottom: 2, right: 0)
        tokenField.textFieldTextColor = UIColor.hex("#00CE15")
    }
}

extension TaskCell: ResizingTokenFieldDelegate {
    func resizingTokenField(_ tokenField: ResizingTokenField, willChangeHeight newHeight: CGFloat) {
        tokenFieldHeight = newHeight
        print("newheight: \(newHeight)")
    }
    func resizingTokenField(_ tokenField: ResizingTokenField, shouldRemoveToken token: ResizingTokenFieldToken) -> Bool {
//        viewModel.deleteTag(with: token.title)
        onDeleteTag()
        return false
    }
    
    func resizingTokenFieldShouldCollapseTokens(_ tokenField: ResizingTokenField) -> Bool {
        false
    }
    
    func resizingTokenFieldCollapsedTokensText(_ tokenField: ResizingTokenField) -> String? {
        nil
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, configurationForDefaultCellRepresenting token: ResizingTokenFieldToken) -> DefaultTokenCellConfiguration? {
        ResizingTokenConfiguration()
    }
}

extension TaskCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == tokenField.textField else { return true }
        guard let text = textField.text, !text.isEmpty else { return true }
        addToken(text)
        tokenField.text = nil
        return true
    }
}

extension TaskCell {
    enum Mode {
        case addCell
    }
}
