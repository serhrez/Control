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



final class TaskCell: UITableViewCell {
    static let reuseIdentifier = "taskcell"
    private let plusView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plus")?.withAlignmentRectInsets(.init(top: -2, left: -2, bottom: -2, right: -2)))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let checkboxView = AutoselectCheckboxView()
    private lazy var textField: DeleteDetectingTextField = {
        let textField = DeleteDetectingTextField()
        textField.layoutEdgeInsets = .zero
        textField.attributedPlaceholder = "New To-Do...".at.attributed { attr in
            attr.font(UIFont.systemFont(ofSize: 20, weight: .regular)).foreground(color: .hex("#A4A4A4"))
        }
        textField.textColor = .hex("#242424")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        textField.delegate = self
        return textField
    }()
    private let dateLabel: ALUILabel = {
        let label = ALUILabel()
        label.alignmentRectInsetsValues = .init(top: -2, left: 0, bottom: 0, right: 0)
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
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
    var onDeleteTag: (String) -> Void = { _ in }
    var addToken: (String) -> Void = { _ in }
    var onTaskNameChanged: (String) -> Void = { _ in }
    var onCreatedTask: () -> Void = {  }
    var onSelected: ((Bool) -> Void)? {
        get { checkboxView.onSelected }
        set { checkboxView.onSelected = newValue }
    }
    var onFocused: (Bool) -> Void = { _ in }
    var onDeleteTask: (() -> Void)? {
        get { textField.onDeleteBackwardWhenEmpty }
        set { textField.onDeleteBackwardWhenEmpty = newValue }
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var isConfiguredAsNew: Bool = false
    
    func configureAsNew(tagAllowed: Bool) {
        resetClosureBindings()
        plusView.isHidden = false
        plusView.layer.opacity = 1
        checkboxView.isHidden = false
        checkboxView.layer.opacity = 0
        isConfiguredAsNew = true
        
        textField.text = ""
        dateLabel.text = nil
        tokenField.removeAll()
        checkboxView.configure(priority: .none)
        checkboxView.configure(isChecked: false)
        tokenField.shownState = tagAllowed ? .textField : .none
        tokenField.allowDeletionTags = tagAllowed
        textField.placeholder = "New To-Do..."
    }
        
    func configure(text: String, date: Date?, priority: Priority, isSelected: Bool, tags: [RlmTag], tagAllowed: Bool) {
        resetClosureBindings()
        plusView.isHidden = true
        checkboxView.isHidden = false
        checkboxView.layer.opacity = 1
        textField.text = text
        dateLabel.text = date?.toFormat("yyyy MMM HH:mm")
        checkboxView.configure(priority: priority)
        checkboxView.configure(isChecked: isSelected)
        
        let tokens = tags.map { ResizingToken(title: $0.name) }
        tokenField.removeAll()
        tokenField.append(tokens: tokens)
        
        isConfiguredAsNew = false
        tokenField.shownState = (tagAllowed || !tags.isEmpty) ? .textField : .none
        tokenField.allowDeletionTags = (tagAllowed || !tags.isEmpty)
        textField.placeholder = "To-Do..."
   }
    
    private func resetClosureBindings() {
        onDeleteTag = { _ in }
        addToken = { _ in }
        onTaskNameChanged = { _ in }
        onCreatedTask = { }
        onSelected = { _ in }
        onFocused = { _ in }
        onDeleteTask = { }
    }

    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        tokenField.layoutSubviews()
        tokenField.collectionView.layoutSubviews()
        let dateLabelHeight: CGFloat = !(dateLabel.text?.isEmpty ?? true) ? dateLabel.font.lineHeight + 2 : 0
        var height = (textField.font?.lineHeight ?? 0) + dateLabelHeight
        if tokenFieldHeight > 8.5 {
            height += tokenFieldHeight
        }
        return .init(width: targetSize.width, height: height)
    }

    func setupViews() {
        contentView.layout(plusView).top(2).leading().width(22).height(22)
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
        tokenField.allowDeletionTags = false
        tokenField.hideLabel(animated: false)
        tokenField.font = .systemFont(ofSize: 15, weight: .semibold)
        tokenField.preferredTextFieldReturnKeyType = .done
        tokenField.textFieldAttributedPlaceholder = "Tag".at.attributed { attr in
            attr.foreground(color: UIColor.hex("#00CE15").withAlphaComponent(0.3)).font(.systemFont(ofSize: 15, weight: .semibold))
        }
        tokenField.isHidden = false
        tokenField.textFieldMinWidth = 52.5
        tokenField.shownState = .none
        tokenField.textFieldDelegate = self
        tokenField.contentInsets = .init(top: 6, left: 0, bottom: 2, right: 0)
        tokenField.textFieldTextColor = UIColor.hex("#00CE15")
    }
    
    func bringFocusToTokenField() {
        tokenField.becomeFirstResponder()
    }
    
    func bringFocusToTextField() {
        textField.becomeFirstResponder()
    }
}

extension TaskCell: ResizingTokenFieldDelegate {
    func resizingTokenField(_ tokenField: ResizingTokenField, willChangeHeight newHeight: CGFloat) {
        tokenFieldHeight = newHeight
    }
    func resizingTokenField(_ tokenField: ResizingTokenField, shouldRemoveToken token: ResizingTokenFieldToken) -> Bool {
//        viewModel.deleteTag(with: token.title)
        if tokenField.allowDeletionTags {
            onDeleteTag(token.title)
        }
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onFocused(true)
        guard textField == self.textField && isConfiguredAsNew else { return }
        plusView.animate(.rotate(180), .fadeOut, .duration(1.5))
        checkboxView.animate(.fadeIn, .duration(1.5))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onFocused(false)
        if textField == tokenField.textField {
            tokenField.textField?.text = ""
            return
        }
        guard textField == self.textField else { return }
        onTaskNameChanged(textField.text ?? "")
        if isConfiguredAsNew {
            if textField.text?.isEmpty ?? true {
                plusView.animate(.rotate(0), .fadeIn, .duration(1.5))
                checkboxView.animate(.fadeOut, .duration(1.5))
            } else {
                onCreatedTask() // Should never be optional, but just in case
                resetClosureBindings()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onFocused(false)
        switch textField {
        case tokenField.textField:
            guard let text = textField.text, !text.isEmpty else { textField.resignFirstResponder() ;return true }
            addToken(text)
            tokenField.text = nil
        case self.textField:
            if !(textField.text?.isEmpty ?? true) && isConfiguredAsNew { onTaskNameChanged(textField.text ?? ""); onCreatedTask(); resetClosureBindings() }
            textField.resignFirstResponder()
        default: break
        }
        return true
    }
}

extension TaskCell {
    enum Mode {
        case addCell
    }
}

class DeleteDetectingTextField: UITextField {
    var onDeleteBackwardWhenEmpty: (() -> ())?
    
    override public func deleteBackward() {
        let isEmpty: Bool = text?.isEmpty ?? false
        super.deleteBackward()
        
        if isEmpty {
            onDeleteBackwardWhenEmpty?()
        }
    }
}
