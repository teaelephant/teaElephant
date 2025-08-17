//
//  EnhancedOnboardingView.swift
//  TeaElephant
//
//  Enhanced onboarding experience for new users
//

import SwiftUI

struct EnhancedOnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    imageName: "leaf.circle",
                    title: "Welcome to TeaElephant",
                    description: "Your personal tea collection manager with a modern twist",
                    pageIndex: 0
                )
                .tag(0)
                
                OnboardingPageView(
                    imageName: "qrcode.viewfinder",
                    title: "Smart Tea Tracking",
                    description: "Scan NFC tags or QR codes to instantly add teas to your digital collection",
                    pageIndex: 1
                )
                .tag(1)
                
                OnboardingPageView(
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
                            hasSeenOnboarding = true
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

struct OnboardingPageView: View {
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

// MARK: - Preview
struct EnhancedOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedOnboardingView()
    }
}