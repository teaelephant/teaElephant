//
//  AppDelegate.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 27/08/2023.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("Dispatch")
                    AppState.shared.pageToNavigationTo = "test"
                }
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token: String = deviceToken.map { data in
                            String(format: "%02.2hhx", data)
                        }
                        .joined()
        AuthManager.shared.registerDeviceToken(token)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        // Try again later.
        print(error)
    }
}

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pageToNavigationTo : String?
}
