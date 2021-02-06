//
//  SettingsCell.swift
//  TodoApp
//
//  Created by sergey on 28.12.2020.
//

import Foundation
import UIKit
fileprivate extension UIConfigurationStateCustomKey {
    static let cellData = UIConfigurationStateCustomKey("com.TodoApp.settingsCellData")
}

// Declare an extension on the cell state struct to provide a typed property for this custom state.
private extension UICellConfigurationState {
    var cellData: SettingsCellData? {
        set { self[.cellData] = newValue }
        get { return self[.cellData] as? SettingsCellData }
    }
}
struct SettingsCellData: Hashable {
    var id: String = UUID().uuidString
    var text: String
    var imageName: String
    var imageWidth: CGFloat
    var onClick: () -> Void
    var active: Bool = true
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SettingsCellData, rhs: SettingsCellData) -> Bool {
        lhs.id == rhs.id
    }
}


class SettingsCell: UICollectionViewListCell {
    let imageView = UIImageView()
    let label = UILabel()
    let overlayView = OverlaySelectionView()
    private var data: SettingsCellData? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundConfiguration?.backgroundColor = UIColor(named: "TAAltBackground")
        setupViews()
    }
    
    func updateWithData(_ newData: SettingsCellData) {
        guard data != newData else { return }
        self.data = newData
        self.setNeedsUpdateConfiguration()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        guard let cellData = state.cellData else { return }
        self.imageView.image = UIImage(named: cellData.imageName)?.resize(toWidth: CGFloat(cellData.imageWidth))
        label.text = cellData.text
        label.textColor = cellData.active ? UIColor(named: "TAHeading") : UIColor.hex("#A4A4A4")
        if cellData.active {
        overlayView.setHighlighted(state.isHighlighted)
        }
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.cellData = data
        return state
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.contentMode = .center
        label.textColor = data.flatMap { $0.active ? UIColor(named: "TAHeading") : UIColor(named: "#A4A4A4") } ?? UIColor(named: "TAHeading")!
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        layout(imageView).leading(33).centerY().width(20).height(20)
        layout(label).leading(64).centerY()
        layout(overlayView).edges()
    }
}
