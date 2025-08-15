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
            
            VStack(spacing: 16) {
                if currentPage == 2 {
                    Button("Get Started") {
                        withAnimation {
                            hasCompletedOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        }
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.55, green: 0.71, blue: 0.55))
                    )
                    .transition(.scale)
                } else {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.55, green: 0.71, blue: 0.55))
                    )
                }
                
                Button("Skip") {
                    withAnimation {
                        hasCompletedOnboarding = true
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    }
                }
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(Color(red: 0.96, green: 0.94, blue: 0.89))
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.7))
                .padding(.bottom, 24)
            
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
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