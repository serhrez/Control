//
//  RealmProvider.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmProvider {
    let configuration: Realm.Configuration
    
    internal init(config: Realm.Configuration) {
        configuration = config
    }
    
    var realm: Realm {
        return try! Realm(configuration: configuration)
    }
    
    // MARK: - Archive realm
    private static let archiveConfig = Realm.Configuration(
        fileURL: (try! DirPath.inSharedContainer(archiveConfigPath)),
        schemaVersion: 4)
    
    public static var archive: RealmProvider = {
        return RealmProvider(config: archiveConfig)
    }()
    
    // MARK: - Projects realm
    private static let mainConfig = Realm.Configuration(
        fileURL: (try! DirPath.inSharedContainer(mainConfigPath)),
        schemaVersion: 4)
    
    public static var main: RealmProvider = {
        return RealmProvider(config: mainConfig)
    }()
        
    // MARK: - InMemory realm
    private static let inMemoryConfig = Realm.Configuration(inMemoryIdentifier: "inMemoryIdentifier")
    
    public static var inMemory: RealmProvider = {
        return RealmProvider(config: inMemoryConfig)
    }()
    
    private static let mainConfigPath = "main.realm"
    private static let archiveConfigPath = "archive.realm"
    
    // MARK: - Bundled Projects
    private static let bundled_anyConfig = Realm.Configuration(
        fileURL: try! DirPath.inBundle(bundled_anyConfigPath),
        readOnly: true)
    
    public static var bundled_any: RealmProvider = {
        return RealmProvider(config: bundled_anyConfig)
    }()

    
    private static let bundled_enConfig = Realm.Configuration(
        fileURL: try! DirPath.inBundle(bundled_enConfigPath),
        readOnly: true)
    
    public static var bundled_en: RealmProvider = {
        return RealmProvider(config: bundled_enConfig)
    }()

    private static let bundled_enConfigPath = "bundled-en.realm"
    private static let bundled_anyConfigPath = "bundled-any.realm"

}

extension RealmProvider {
    func safeWrite<Result>(closure: () throws -> Result) {
        do {
            try realm.write {
                try closure()
            }
        } catch {
            print("⚠️⚠️⚠️ Realm error: \(error.localizedDescription)")
            #if DEBUG
                fatalError()
            #endif
        }
    }
    func addInboxProjectToRealm() {
        let isInboxInRealm = realm.objects(RlmProject.self).contains { $0.id == Constants.inboxId }
        guard !isInboxInRealm else { return }
        do {
            try realm.write {
                let project = RlmProject(name: "Inbox".localizable(), icon: .assetImage(name: "inboximg", tintHex: "#571cff"), notes: "", color: .hex("#571cff"), date: Date())
                project.id = Constants.inboxId
                realm.add(project)
            }
        } catch {
            print("⚠️⚠️⚠️ Realm error: \(error.localizedDescription)")
            #if DEBUG
                fatalError()
            #endif
        }
    }
}
