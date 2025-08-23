//
//  AppDelegate.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 27/08/2023.
//

import SwiftUI
@preconcurrency import UserNotifications

@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
        // start notification while app is in Foreground
        UNUserNotificationCenter.current().delegate = self
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    // This function will be called right after user tap on the notification
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AppState.shared.pageToNavigationTo = .showCard
            AppState.shared.notificationMessage = response.notification.request.content.body
            AppState.shared.id = response.notification.request.content.threadIdentifier
        }
        print("app opened from PushNotification tap")
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
        completionHandler()
    }
}
