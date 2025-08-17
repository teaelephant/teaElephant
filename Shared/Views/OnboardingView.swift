//
//  OnboardingView.swift (Views)
//  TeaElephant
//
//  This file re-exports the OnboardingView from the Onboarding folder
//  to avoid duplicate filename issues in the build
//

import SwiftUI

// Re-export from the actual implementation
public typealias OnboardingViewAlias = OnboardingViewActual

// Wrapper to avoid naming conflicts
struct OnboardingViewActual: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageViewWrapper(
                    imageName: "leaf.circle",
                    title: "Welcome to TeaElephant",
                    description: "Your personal tea collection manager with a modern twist",
                    pageIndex: 0
                )
                .tag(0)
                
                OnboardingPageViewWrapper(
                    imageName: "qrcode.viewfinder",
                    title: "Smart Tea Tracking",
                    description: "Scan NFC tags or QR codes to instantly add teas to your digital collection",
                    pageIndex: 1
                )
                .tag(1)
                
                OnboardingPageViewWrapper(
                    imageName: "arkit",
                    title: "Augmented Reality",
                    description: "Visualize your tea collection in AR and get AI-powered recommendations based on your mood",
                    pageIndex: 2
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack(spacing: TeaSpacing.medium) {
                if currentPage == 2 {
                    Button("Get Started") {
                        withAnimation {
                            hasCompletedOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        }
                    }
                    .buttonStyle(TeaPrimaryButtonStyle())
                    .transition(.scale)
                } else {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(TeaPrimaryButtonStyle())
                }
                
                Button("Skip") {
                    withAnimation {
                        hasCompletedOnboarding = true
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    }
                }
                .font(TeaTypography.callout)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, TeaSpacing.xLarge)
            .padding(.bottom, TeaSpacing.xLarge)
        }
        .background(Color.teaBackground)
    }
}

struct OnboardingPageViewWrapper: View {
    let imageName: String
    let title: String
    let description: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: TeaSpacing.xLarge) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.teaPrimary)
                .padding(.bottom, TeaSpacing.large)
            
            Text(title)
                .font(TeaTypography.title)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(TeaTypography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TeaSpacing.xLarge)
            
            Spacer()
            Spacer()
        }
    }
}