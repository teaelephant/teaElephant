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
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                SimpleOnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

// Simple onboarding view embedded in the same file
struct SimpleOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPage(
                    imageName: "leaf.circle",
                    title: "Welcome to TeaElephant",
                    description: "Your personal tea collection manager with a modern twist",
                    pageIndex: 0
                )
                .tag(0)
                
                OnboardingPage(
                    imageName: "qrcode.viewfinder",
                    title: "Smart Tea Tracking",
                    description: "Scan NFC tags or QR codes to instantly add teas to your digital collection",
                    pageIndex: 1
                )
                .tag(1)
                
                OnboardingPage(
                    imageName: "arkit",
                    title: "Augmented Reality",
                    description: "Visualize your tea collection in AR and get AI-powered recommendations",
                    pageIndex: 2
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack(spacing: 16) {
                if currentPage == 2 {
                    Button("Get Started") {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                } else {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
                
                Button("Skip") {
                    hasCompletedOnboarding = true
                }
                .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}
