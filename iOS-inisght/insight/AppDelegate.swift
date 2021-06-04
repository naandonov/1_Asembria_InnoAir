//
//  AppDelegate.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let trackingManager = TrackingManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let _: UserEntity = StorageManager.shared.getItem() {} else {
            StorageManager.shared.setItem(UserEntity(id: UUID().uuidString))
        }
        
        trackingManager.handleLocationServiceAuthorization()
        trackingManager.startListentingForBeaconsInProximity()
        return true
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

