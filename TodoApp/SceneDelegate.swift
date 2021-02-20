//
//  SceneDelegate.swift
//  TodoApp
//
//  Created by sergey on 07.11.2020.
//

import UIKit
import SwiftDate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        SwiftDate.defaultRegion = .current
        _ = InAppManager.shared
        let window = UIWindow(windowScene: windowScene)
//        if UserDefaultsWrapper.shared.debugDeleteDb {
//            do {
//                try FileManager.default.removeItem(at: DirPath.inSharedContainer("main.realm"))
//                try FileManager.default.removeItem(at: DirPath.inSharedContainer("archive.realm"))
//            } catch {
//                print(error.localizedDescription)
//            }
//            PredefinedRealm.populateRealm(RealmProvider.main.realm)
//            if !(RealmProvider.main.configuration.fileURL.flatMap { DirPath.fileExists($0) } ?? false) {
//                try! FileManager.default.copyItem(at: RealmProvider.bundled.configuration.fileURL!, to: RealmProvider.main.configuration.fileURL!)
//            }
//        }
        if !(RealmProvider.main.configuration.fileURL.flatMap { DirPath.fileExists($0) } ?? false) {
            let languagePrefix = Locale.preferredLanguages[0]
            if languagePrefix == "en" {
                try! FileManager.default.copyItem(at: RealmProvider.bundled.configuration.fileURL!, to: RealmProvider.main.configuration.fileURL!)
            }
        }
        let viewController = AllProjectsVc()

        let navigationVc = TANavigationController(rootViewController: viewController)
        AppNavigationRouter.shared.navigationController = navigationVc

        window.rootViewController = navigationVc
        
        self.window = window
        window.makeKeyAndVisible()
//        LaunchScreenManager().animateAfterLaunch(window.rootViewController!.view)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

