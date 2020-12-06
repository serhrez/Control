//
//  ResizingTokenField.swift
//  ResizingTokenField
//
//  Created by Tadej Razborsek on 19/06/2019.
//  Copyright © 2019 Tadej Razborsek. All rights reserved.
//

import UIKit

open class ResizingTokenField: UIView, UICollectionViewDataSource, UICollectionViewDelegate, ResizingTokenFieldFlowLayoutDelegate {
    
    /// List of currently displayed tokens.
    var tokens: [ResizingTokenFieldToken] { return viewModel.tokens }
    public var maxHeight: CGFloat? {
        didSet {
            collectionView.reloadData()
        }
    }
    // MARK: - Configuration
    
    public var itemHeight: CGFloat {
        get { return viewModel.itemHeight }
        set {
            viewModel.customItemHeight = newValue
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    /// Insets of the internal collection view layout.
    public var contentInsets: UIEdgeInsets = Constants.Default.contentInsets {
        didSet {
            (collectionView.collectionViewLayout as? ResizingTokenFieldFlowLayout)?.sectionInset = contentInsets
        }
    }
    
    /// Spacing between items.
    public var itemSpacing: CGFloat = Constants.Default.itemSpacing {
        didSet {
            (collectionView.collectionViewLayout as? ResizingTokenFieldFlowLayout)?.minimumInteritemSpacing = itemSpacing
        }
    }
    
    /// Font used by the token field.
    public var font: UIFont {
        get { return viewModel.font }
        set { viewModel.font = newValue }
    }
    
    // MARK: Label
    
    public var isShowingLabel: Bool { return viewModel.isShowingLabelCell }
    
    /// Text to display in the label at the start.
    public var labelText: String? {
        get { return viewModel.labelCellText }
        set { viewModel.labelCellText = newValue }
    }
    
    /// Text color of the label at the start.
    public var labelTextColor: UIColor = Constants.Default.labelTextColor {
        didSet {
            if viewModel.isShowingLabelCell {
                collectionView.reloadItems(at: [viewModel.labelCellIndexPath])
            }
        }
    }
    
    public var shownState: ShownState {
        get {
            viewModel.shownState
        }
        set {
            viewModel.shownState = newValue
        }
    }
    
    // MARK: Text field
    
    /// Reference to the current text field instance, or nil if no text field is loaded.
    /// The internal collection view cell for this text field is reloaded as few times as possible, but this reference might still change.
    public var textField: UITextField? { return (collectionView.cellForItem(at: viewModel.textFieldCellIndexPath) as? TextFieldCell)?.textField }
    
    /// Text color for the text field.
    public var textFieldTextColor: UIColor = Constants.Default.textFieldTextColor {
        didSet { textField?.textColor = textFieldTextColor }
    }
    
    /// Set to true to make text field first responder immediately after it loads.
    /// If `textField` returns a non-nil value it should be used instead of this flag.
    public var makeTextFieldFirstResponderImmediately: Bool = false
    
    /// Minimum allowed width of the text field. Will be stretched to the end of the last row.
    public var textFieldMinWidth: CGFloat {
        get { return viewModel.textFieldCellMinWidth }
        set { viewModel.textFieldCellMinWidth = newValue }
    }
    
    /// Text field return key type.
    public var preferredTextFieldReturnKeyType: UIReturnKeyType = .default {
        didSet { textField?.returnKeyType = preferredTextFieldReturnKeyType }
    }
    
    /// Placeholder shown by the text field.
    public var placeholder: String? {
        didSet { textField?.placeholder = placeholder }
    }
    
    /// Use to get/set currently displayed text.
    public var text: String? {
        get { return cachedText ?? textField?.text }
        set {
            if let textField = self.textField {
                textField.text = newValue
                textField.sendActions(for: .editingChanged)
            } else {
                cachedText = newValue
            }
        }
    }
    private var cachedText: String? // If text is set before text field cell is loaded.
    
    // MARK: Animation
    
    /// Duration of all animations performed by the token field.
    public var animationDuration: TimeInterval = Constants.Default.animationDuration
    
    /// Use to control animation when tokens are removed due to text input.
    /// For example, if user taps backspace while a token is selected.
    public var shouldTextInputRemoveTokensAnimated: Bool = true
    
    /// If `true` tokens will be collapsed using animation.
    public var shouldCollapseTokensAnimated: Bool = true
    
    /// If `true` tokens will be expanded using animation.
    public var shouldExpandTokensAnimated: Bool = true
    public var onPlusButtonClicked: (() -> Void)? {
        didSet {
            guard viewModel.shownState != .textField else { return }
            viewModel.shownState = onPlusButtonClicked == nil ? .none : .add
            collectionView.reloadData()
        }
    }
    public var allowDeletionTags: Bool = false
    
    // MARK: Delegates
    
    public weak var delegate: ResizingTokenFieldDelegate?
    public weak var customCellDelegate: ResizingTokenFieldCustomCellDelegate? {
        didSet { registerCells() }
    }
    public weak var textFieldDelegate: UITextFieldDelegate? {
        didSet { textField?.delegate = textFieldDelegate }
    }
    
    // MARK: - Initialization
    
    let viewModel: ResizingTokenFieldViewModel = ResizingTokenFieldViewModel()
    public let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: ResizingTokenFieldFlowLayout())
    
    /// Tracks when the initial collection view load is performed.
    /// This flag is used to prevent crashes from trying to insert/delete items before the initial load.
    private var isCollectionViewLoaded: Bool = false
    
    /// Height constraint of the collection view. This constraint's constant is updated as collection view resizes.
    public var heightConstraint: NSLayoutConstraint?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private func initialize() {
        setUpCollectionView()
        registerCells()
    }
    
    private func setUpCollectionView() {
        (collectionView.collectionViewLayout as? ResizingTokenFieldFlowLayout)?.sectionInset = contentInsets
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        heightConstraint = NSLayoutConstraint(item: collectionView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 0)
        heightConstraint!.priority = UILayoutPriority(rawValue: 999) // To avoid constraint issues when used in a UIStackView
        addConstraint(heightConstraint!)
    }
    
    private func registerCells() {
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: Constants.Identifier.labelCell)
        collectionView.register(TextFieldCell.self, forCellWithReuseIdentifier: Constants.Identifier.textFieldCell)
        collectionView.register(PlusCell.self, forCellWithReuseIdentifier: Constants.Identifier.addCell)

        
        if let customClass = customCellDelegate?.resizingTokenFieldCustomTokenCellClass(self) {
            collectionView.register(customClass, forCellWithReuseIdentifier: Constants.Identifier.tokenCell)
        } else if let customNib = customCellDelegate?.resizingTokenFieldCustomTokenCellNib(self) {
            collectionView.register(customNib, forCellWithReuseIdentifier: Constants.Identifier.tokenCell)
        } else {
            collectionView.register(DefaultTokenCell.self, forCellWithReuseIdentifier: Constants.Identifier.tokenCell)
        }
    }
    
    // MARK: - Content
    
    /// Use to invalidate the internal collection view layout.
    /// For example, use this to handle rotation change.
    public func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    /// Use to reload the internal collection view data.
    public func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: - First responder
    
    public override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField?.becomeFirstResponder() == true
    }
    
    public override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        if let textField = self.textField, textField.isFirstResponder {
            return textField.resignFirstResponder()
        } else {
            for cell in collectionView.visibleCells {
                guard let cell = cell as? ResizingTokenFieldTokenCell else { continue }
                if cell.isFirstResponder {
                    return cell.resignFirstResponder()
                }
            }
        }
        
        return false
    }
    
    // MARK: - Toggle label
    
    public func showLabel(animated: Bool = false, completion: ((_ finished: Bool) -> Void)? = nil) {
        toggleLabelCell(visible: true, animated: animated, completion: completion)
    }
    
    public func hideLabel(animated: Bool = false, completion: ((_ finished: Bool) -> Void)? = nil) {
        toggleLabelCell(visible: false, animated: animated, completion: completion)
    }
    
    /// Shows/hides the label cell.
    private func toggleLabelCell(visible: Bool, animated: Bool, completion: ((_ finished: Bool) -> Void)?) {
        guard viewModel.isShowingLabelCell != visible else {
            completion?(true)
            return
        }
        
        viewModel.isShowingLabelCell = visible
        
        guard isCollectionViewLoaded else {
            // Collection view initial load was not performed yet, items will be correctly configured there.
            completion?(true)
            return
        }
        
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                visible ? self.collectionView.insertItems(at: [self.viewModel.labelCellIndexPath]) : self.collectionView.deleteItems(at: [self.viewModel.labelCellIndexPath])
            }, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                visible ? self.collectionView.insertItems(at: [self.viewModel.labelCellIndexPath]) : self.collectionView.deleteItems(at: [self.viewModel.labelCellIndexPath])
            }
        }
    }
    
    // MARK: - Add/remove tokens
    
    public func append(tokens: [ResizingTokenFieldToken], animated: Bool = false, completion: ((_ finished: Bool) -> Void)? = nil) {
        let newIndexPaths = viewModel.append(tokens: tokens)
        insertItems(atIndexPaths: newIndexPaths, animated: animated, completion: completion)
    }
    
    /// Remove provided tokens, if they are in the token field.
    public func remove(tokens: [ResizingTokenFieldToken], animated: Bool = false, completion: ((_ finished: Bool) -> Void)? = nil) {
        let removedIndexPaths = viewModel.remove(tokens: tokens)
        removeItems(atIndexPaths: removedIndexPaths, animated: animated, completion: completion)
    }
    
    /// Remove tokens at provided indexes, if they are in the token field.
    /// This function is faster than `remove(tokens:)`.
    public func remove(tokensAtIndexes indexes: IndexSet, animated: Bool = false, completion: ((_ finished: Bool) -> Void)? = nil) {
        let removedIndexPaths = viewModel.remove(tokensAtIndexes: indexes)
        removeItems(atIndexPaths: removedIndexPaths, animated: animated, completion: completion)
    }
    
    /// Removes all tokens.
    public func removeAllTokens(animated: Bool = false, completion: ((_ finished: Bool) -> Void)? = nil) {
        let removedIndexPaths = viewModel.removeAllTokens()
        removeItems(atIndexPaths: removedIndexPaths, animated: animated, completion: completion)
    }
    
    public func removeAll() {
        viewModel.tokens = []
        collectionView.reloadData()
    }
    
    private func insertItems(atIndexPaths indexPaths: [IndexPath], animated: Bool, completion: ((_ finished: Bool) -> Void)?) {
        guard isCollectionViewLoaded, !indexPaths.isEmpty else {
            updateCollapsedTextIfNeeded()
            completion?(true)
            return
        }
        
        updateCollapsedTextIfNeeded()
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                self.collectionView.insertItems(at: indexPaths)
            }, completion: completion)
        } else {
            collectionView.reloadData()
            completion?(true)
        }
    }
    
    private func removeItems(atIndexPaths indexPaths: [IndexPath], animated: Bool, completion: ((_ finished: Bool) -> Void)?) {
        guard isCollectionViewLoaded, !indexPaths.isEmpty else {
            updateCollapsedTextIfNeeded()
            completion?(true)
            return
        }
        
        updateCollapsedTextIfNeeded()
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                self.collectionView.deleteItems(at: indexPaths)
            }, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                collectionView.deleteItems(at: indexPaths)
            }
            completion?(true)
        }
    }
    
    // MARK: - Collapse/expand tokens
    
    private func collapseTokens(animated: Bool, completion: ((_ finished: Bool) -> Void)?) {
        textField?.text = delegate?.resizingTokenFieldCollapsedTokensText(self)
        let indexPaths = viewModel.toggle(areTokensCollapsed: true)
        removeItems(atIndexPaths: indexPaths, animated: animated, completion: completion)
    }
    
    private func expandTokens(animated: Bool, completion: ((_ finished: Bool) -> Void)?) {
        textField?.text = nil
        let indexPaths = viewModel.toggle(areTokensCollapsed: false)
        insertItems(atIndexPaths: indexPaths, animated: animated, completion: completion)
    }
    
    private func updateCollapsedTextIfNeeded() {
        guard viewModel.areTokensCollapsed else { return }
        textField?.text = delegate?.resizingTokenFieldCollapsedTokensText(self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isCollectionViewLoaded = true
        return viewModel.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.identifierForCell(atIndexPath: indexPath),
                                                      for: indexPath)
        switch cell {
        case let plusCell as PlusCell:
            populate(plusCell: plusCell, atIndexPath: indexPath)
        case let tokenCell as ResizingTokenFieldTokenCell:
            populate(tokenCell: tokenCell, atIndexPath: indexPath)
        case let labelCell as LabelCell:
            populate(labelCell: labelCell, atIndexPath: indexPath)
        case let textFieldCell as TextFieldCell:
            populate(textFieldCell: textFieldCell, atIndexPath: indexPath)
        default:
            // Should never reach.
            break
        }
        
        return cell
    }
    
    private func populate(plusCell: PlusCell, atIndexPath indexPath: IndexPath) {}
    
    private func populate(tokenCell: ResizingTokenFieldTokenCell, atIndexPath indexPath: IndexPath) {
        guard let token = viewModel.token(atIndexPath: indexPath) else {
            tokenCell.onRemove = nil
            return
        }
        
        if let defaultTokenCell = tokenCell as? DefaultTokenCell {
            defaultTokenCell.titleLabel.font = viewModel.font
            let configuration = delegate?.resizingTokenField(self, configurationForDefaultCellRepresenting: token)
            defaultTokenCell.configuration = configuration ?? Constants.Default.defaultTokenCellConfiguration
            defaultTokenCell.allowSelection = allowDeletionTags
        }
        
        tokenCell.populate(withToken: token)
        tokenCell.onRemove = { [weak self] (text) in
            guard let self = self else { return }
            guard text == nil && self.delegate?.resizingTokenField(self, shouldRemoveToken: token) != false else { return }
            self.remove(tokens: [token], animated: self.shouldTextInputRemoveTokensAnimated)
            _ = self.textField?.becomeFirstResponder()
            self.text = text
        }
    }
    
    private func populate(labelCell: LabelCell, atIndexPath indexPath: IndexPath) {
        labelCell.label.font = viewModel.font
        labelCell.label.textColor = labelTextColor
        labelCell.label.text = viewModel.labelCellText
    }
    
    public var textFieldAttributedPlaceholder: NSAttributedString?
    
    private func populate(textFieldCell: TextFieldCell, atIndexPath indexPath: IndexPath) {
        if let text = cachedText {
            cachedText = nil
            textFieldCell.textField.text = text
        }
        
        textFieldCell.textField.placeholder = placeholder
        if let t = textFieldAttributedPlaceholder { textFieldCell.textField.attributedPlaceholder = t }
        textFieldCell.textField.font = viewModel.font
        textFieldCell.textField.returnKeyType = preferredTextFieldReturnKeyType
        textFieldCell.textField.delegate = textFieldDelegate
        textFieldCell.textField.textColor = textFieldTextColor
        textFieldCell.textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        textFieldCell.textField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        textFieldCell.textField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        textFieldCell.onDeleteBackwardWhenEmpty = { [weak self] in self?.selectLastToken() }
        
        if makeTextFieldFirstResponderImmediately {
            makeTextFieldFirstResponderImmediately = false
            textFieldCell.textField.becomeFirstResponder()
        }
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        delegate?.resizingTokenField(self, didEditText: textField.text)
    }
    
    @objc private func textFieldEditingDidBegin(_ textField: UITextField) {
        expandTokens(animated: shouldExpandTokensAnimated, completion: nil)
    }
    
    @objc private func textFieldEditingDidEnd(_ textField: UITextField) {
        if delegate?.resizingTokenFieldShouldCollapseTokens(self) == true {
            let isTokenFirstResponder: Bool = collectionView.visibleCells.contains(where: {
                $0.isFirstResponder || ($0 as? ResizingTokenFieldTokenCell)?.isBecomingFirstResponder == true
            })
            
            if !isTokenFirstResponder {
                collapseTokens(animated: shouldCollapseTokensAnimated, completion: nil)
            }
        }
    }
    
    private func selectLastToken() {
        if let indexPath = viewModel.lastTokenCellIndexPath, let cell = collectionView.cellForItem(at: indexPath) as? ResizingTokenFieldTokenCell {
            _ = cell.becomeFirstResponder()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ResizingTokenFieldTokenCell, allowDeletionTags {
            _ = cell.becomeFirstResponder()
        } else if collectionView.cellForItem(at: indexPath) as? PlusCell != nil {
            onPlusButtonClicked?()
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let identifier = viewModel.identifierForCell(atIndexPath: indexPath)
        switch identifier {
        case Constants.Identifier.labelCell:
            return viewModel.labelCellSize
        case Constants.Identifier.textFieldCell:
            return viewModel.textFieldCellMinSize   // Will be stretched by layout if needed
        case Constants.Identifier.tokenCell:
            if let token = viewModel.token(atIndexPath: indexPath) {
                if let delegate = customCellDelegate {
                    return CGSize(width: delegate.resizingTokenField(self, tokenCellWidthForToken: token),
                                  height: itemHeight)
                }
                
                return viewModel.defaultTokenCellSize(forToken: token)
            }
        case Constants.Identifier.addCell:
            return viewModel.addCellSize
        default:
            break
        }
        
        // Should never reach
        return .zero
    }
    
    // MARK: - ResizingTokenFieldFlowLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout: ResizingTokenFieldFlowLayout, heightDidChange newHeight: CGFloat) {        
        delegate?.resizingTokenField(self, willChangeHeight: newHeight)
        heightConstraint?.constant = newHeight
        delegate?.resizingTokenField(self, didChangeHeight: newHeight)
    }
    
    func lastCellIndexPath(in collectionView: UICollectionView, layout: ResizingTokenFieldFlowLayout) -> IndexPath {
        return viewModel.textFieldCellIndexPath
    }

}
