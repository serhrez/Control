//
//  DebugSettingsVc.swift
//  TodoApp
//
//  Created by sergey on 02.02.2021.
//

import Foundation
import UIKit
import Eureka
import RealmSwift

class DebugSettingsVc: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TAAltBackground")
        form +++ Section("Constants")
            <<< debugTextRow(title: "navigationTitleFontSize", value: "\(Constants.navigationTitleFontSize)", valueConvert: { CGFloat($0) }, onChange: { value in
                Constants.navigationTitleFontSize = value
            })
            <<< debugTextRow(title: "vcMinBottomPadding", value: "\(Constants.vcMinBottomPadding)", valueConvert: { CGFloat($0) }, onChange: { value in
                Constants.vcMinBottomPadding = value
            })
            <<< debugTextRow(title: "animationDefaultDuration", value: "\(Constants.animationDefaultDuration)", valueConvert: { TimeInterval($0) }, onChange: { value in
                Constants.animationDefaultDuration = value
            })
            <<< debugTextRow(title: "animationBottomMessagesDuration", value: "\(Constants.animationBottomMessagesDuration)", valueConvert: { TimeInterval($0) }, onChange: { value in
                Constants.animationBottomMessagesDuration = value
            })
            <<< debugTextRow(title: "topInsetSpacingBetweenSearchBarAndElements", value: "\(Constants.topInsetSpacingBetweenSearchBarAndElements)", valueConvert: { CGFloat($0) }, onChange: { value in
                Constants.topInsetSpacingBetweenSearchBarAndElements = value
            })
        form +++ Section("Features")
            <<< debugSwitchRow(title: "premium", value: KeychainWrapper.shared.isPremium, onChange: { value in
                KeychainWrapper.shared.isPremium = value
            })
            <<< debugSwitchRow(title: "didOnboard", value: UserDefaultsWrapper.shared.didOnboard, onChange: { value in
                UserDefaultsWrapper.shared.didOnboard = value
            })
        form +++ Section("Database")
            <<< debugSwitchRow(title: "delete database on start", value: UserDefaultsWrapper.shared.debugDeleteDb, onChange: { value in
                UserDefaultsWrapper.shared.debugDeleteDb = value
            })
            <<< debugButtonRow(title: "Clear main database", onClick: {
                RealmProvider.main.realm.objects(RlmTask.self).forEach { task in
                    Notifications.shared.removeNotifications(id: task.id)
                }
                RealmProvider.main.safeWrite {
                    RealmProvider.main.realm.deleteAll()
                }
                RealmProvider.main.addInboxProjectToRealm()
            })
            <<< debugButtonRow(title: "Clear archive database", onClick: {
                RealmProvider.archive.safeWrite {
                    RealmProvider.archive.realm.deleteAll()
                }
            })
    }
    
    func debugTextRow<T>(title: String, value: String, valueConvert: @escaping (String) -> T?, onChange: @escaping (T) -> Void) -> TextRow {
        return TextRow() { row in
            row.title = title
            row.value = value
        }.onChange { row in
            guard let value = row.value else { return }
            guard let converted = valueConvert(value) else { return }
            onChange(converted)
        }
    }
    
    func debugSwitchRow(title: String, value: Bool, onChange: @escaping (Bool) -> Void) -> SwitchRow {
        return SwitchRow() { row in
            row.title = title
            row.value = value
        }.onChange { row in
            onChange(row.value ?? false)
        }
    }
    
    func debugButtonRow(title: String, onClick: @escaping () -> Void) -> ButtonRow {
        return ButtonRow() { row in
            row.title = title
        }.onCellSelection({ (cell, row) in
            onClick()
        })
    }
}

extension CGFloat {
    init?(_ string: String) {
        guard let float = Float(string) else { return nil }
        let cgFloat = CGFloat(float)
        self = cgFloat
    }
}
