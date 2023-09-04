//
//  AppDelegate.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 27/08/2023.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        // start notification while app is in Foreground
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AppState.shared.pageToNavigationTo = .showCard
            AppState.shared.notificationMessage = response.notification.request.content.body
            AppState.shared.id = response.notification.request.content.threadIdentifier
        }
        print("app opened from PushNotification tap")
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
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
