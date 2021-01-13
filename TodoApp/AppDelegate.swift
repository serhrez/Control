//
//  AppDelegate.swift
//  TodoApp
//
//  Created by sergey on 07.11.2020.
//

import UIKit
||||||| parent of 2c9a98f... notifications properly set up and wired up
import SwiftyStoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    func applyTransparentBackgroundToTheNavigationBar(navigationController: UINavigationController, _ opacity: CGFloat) {
        var transparentBackground: UIImage
        
        /** The background of a navigation bar switches from being translucent to transparent when a background image is applied.
            The intensity of the background image's alpha channel is inversely related to the transparency of the bar.
            That is, a smaller alpha channel intensity results in a more transparent bar and vise-versa.

              Below, a background image is dynamically generated with the desired opacity.
        */
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1),
                                               false,
                                               navigationController.navigationBar.layer.contentsScale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: opacity)
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        transparentBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        /** Use the appearance proxy to customize the appearance of UIKit elements.
            However changes made to an element's appearance proxy do not affect any existing instances of that element currently
               in the view hierarchy. Normally this is not an issue because you will likely be performing your appearance customizations in
            -application:didFinishLaunchingWithOptions:. However, this example allows you to toggle between appearances at runtime
            which necessitates applying appearance customizations directly to the navigation bar.
        */

        let navigationBarAppearance = navigationController.navigationBar
        navigationBarAppearance.setBackgroundImage(transparentBackground, for: .default)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

