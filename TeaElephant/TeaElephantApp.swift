//
//  TeaElephantApp.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 16.07.2020.
//

import SwiftUI

@main
struct TeaElephantApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding || hasSeenOnboarding {
                ContentView()
            } else {
                InteractiveOnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

// Removed old onboarding views - now using InteractiveOnboardingView
