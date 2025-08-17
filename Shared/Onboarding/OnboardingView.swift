//
//  OnboardingView.swift
//  TeaElephant
//
//  Onboarding experience for new users
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
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
            
            VStack(spacing: TeaSpacingAlt.medium) {
                if currentPage == 2 {
                    Button("Get Started") {
                        withAnimation {
                            hasCompletedOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        }
                    }
                    .buttonStyle(TeaPrimaryButtonStyleAlt())
                    .transition(.scale)
                } else {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(TeaPrimaryButtonStyleAlt())
                }
                
                Button("Skip") {
                    withAnimation {
                        hasCompletedOnboarding = true
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    }
                }
                .font(TeaTypographyAlt.callout)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, TeaSpacingAlt.xLarge)
            .padding(.bottom, TeaSpacingAlt.xLarge)
        }
        .background(Color.teaBackgroundAlt)
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: TeaSpacingAlt.xLarge) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.teaPrimaryAlt)
                .padding(.bottom, TeaSpacingAlt.large)
            
            Text(title)
                .font(TeaTypographyAlt.title)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(TeaTypographyAlt.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TeaSpacingAlt.xLarge)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}