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
    
    // MARK: - Projects realm
    private static let mainConfig = Realm.Configuration(
        fileURL: try! DirPath.inLibrary(mainConfigPath),
        schemaVersion: 4)
    
    public static var main: RealmProvider = {
        return RealmProvider(config: mainConfig)
    }()
    
    // MARK: - Bundled Projects
    private static let bundledConfig = Realm.Configuration(
        fileURL: try! DirPath.inBundle(bundledConfigPath),
        readOnly: true)
    
    public static var bundled: RealmProvider = {
        return RealmProvider(config: bundledConfig)
    }()
    
    // MARK: - InMemory realm
    private static let inMemoryConfig = Realm.Configuration(inMemoryIdentifier: "inMemoryIdentifier")
    
    public static var inMemory: RealmProvider = {
        return RealmProvider(config: inMemoryConfig)
    }()
    
    static let mainConfigPath = "main.realm"
    static let bundledConfigPath = "bundled.realm"
}
