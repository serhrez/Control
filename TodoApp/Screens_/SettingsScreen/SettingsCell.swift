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
    private var data: SettingsCellData? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func updateWithData(_ newData: SettingsCellData) {
        guard data != newData else { return }
        self.data = newData
        setNeedsUpdateConfiguration()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        guard let cellData = state.cellData else { return }
        self.imageView.image = UIImage(named: cellData.imageName)?.resize(toWidth: CGFloat(cellData.imageWidth))
        label.text = cellData.text
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
        label.textColor = UIColor(named: "TAHeading")!
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        layout(imageView).leading(33).centerY().width(20).height(20)
        layout(label).leading(64).centerY()
    }
}
