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
        if UserDefaultsWrapper.shared.debugDeleteDb {
            do {
                try FileManager.default.removeItem(at: DirPath.inLibrary("main.realm"))
                try FileManager.default.removeItem(at: DirPath.inLibrary("archive.realm"))
            } catch {
                print(error.localizedDescription)
            }
            PredefinedRealm.populateRealm(RealmProvider.main.realm)
        }
//        let viewController = TaskDetailsVc(viewModel: .init(task: RealmProvider.main.realm.objects(RlmTask.self).filter { $0.name == "Empty task" }.first!))
//        let viewController = CalendarVc(viewModel: .init(reminder: nil, repeat: nil, date: nil), onDone: { print($0, $1, $2) })
//        let tag1 = RealmProvider.main.realm.objects(RlmTag.self).filter { $0.name == "Work" }.first!
//        let viewController = TagDetailVc(viewModel: .init(tag: tag1))
//        let viewController = TimePickerVc(hours: 12, minutes: 23, onDone: { print($0) })
//        let viewController = SearchVc()
//        let viewController = CreateProjectVc(viewModel: .init())
//        let viewController = PlannedVc()
//        let viewController = ArchiveVc(viewModel: .init())
//        let viewController = AllTagsVc(mode: .selection(selected: [], { print($0) }))
//        let viewController = InboxTasksVc()
//        let viewController = ProjectDetailsVc()
//        let viewController = CreateProjectVc()
//        let project = RealmProvider.main.realm.objects(RlmProject.self).first(where: { $0.name == "Inbox" })
//        let viewController = ProjectDetailsVc(project: project!)
//        let viewController = TagPicker(viewSource: UIView(frame: .init(x: 200, y: 600, width: 50, height: 50)), items: ["Work", "Plan", "Important"], finished: { print($0) })
//        let viewController = IconPickerFullVc(onSelected: { print($0) })
//        let viewController = SettingsVc()
//        let viewController = SettingsVc()
        let viewController = AllProjectsVc()

        let navigationVc = TANavigationController(rootViewController: viewController)
        AppNavigationRouter.shared.navigationController = navigationVc

        window.rootViewController = navigationVc
        
        self.window = window
        window.makeKeyAndVisible()
        LaunchScreenManager().animateAfterLaunch(window.rootViewController!.view)
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

