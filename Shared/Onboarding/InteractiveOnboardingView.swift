//
//  InteractiveOnboardingView.swift
//  TeaElephant
//
//  Interactive onboarding experience with tutorial elements
//

import SwiftUI
import AVKit

struct InteractiveOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var showInteractiveDemo = false
    @State private var demoStep = 0
    @State private var hasInteracted = [false, false, false, false]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.teaBackgroundAlt,
                    Color.teaPrimaryAlt.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                
                // Content
                TabView(selection: $currentPage) {
                    welcomePage
                        .tag(0)
                    
                    scanningTutorial
                        .tag(1)
                    
                    arPreview
                        .tag(2)
                    
                    personalizedExperience
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
            
            // Interactive overlay
            if showInteractiveDemo {
                interactiveDemoOverlay
            }
        }
    }
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index <= currentPage ? Color.teaPrimaryAlt : Color.glassBorder)
                    .frame(height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
    
    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.teaPrimaryAlt.opacity(0.2),
                                Color.vibrantGreen.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(Color.teaPrimaryAlt)
                    .symbolEffect(.pulse.byLayer, options: .repeating, value: true)
            }
            
            VStack(spacing: 16) {
                Text("Welcome to TeaElephant")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color.teaTextPrimaryAlt)
                    .multilineTextAlignment(.center)
                
                Text("Your personal tea companion")
                    .font(.system(size: 18))
                    .foregroundColor(Color.teaTextSecondaryAlt)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // Feature highlights
            VStack(spacing: 20) {
                featureRow(icon: "checkmark.circle.fill", text: "Track your tea collection")
                featureRow(icon: "checkmark.circle.fill", text: "Get personalized recommendations")
                featureRow(icon: "checkmark.circle.fill", text: "Explore teas in AR")
            }
            .padding(.horizontal, 60)
            
            Spacer()
        }
    }
    
    private var scanningTutorial: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Smart Tea Tracking")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.teaTextPrimaryAlt)
            
            // Interactive QR demo
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(width: 250, height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                
                if !hasInteracted[1] {
                    // QR code animation
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 100))
                        .foregroundColor(Color.vibrantBlue)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                hasInteracted[1] = true
                                showScanAnimation()
                            }
                        }
                    
                    Text("Tap to try scanning")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.vibrantBlue)
                        .offset(y: 80)
                } else {
                    // Success state
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.vibrantGreen)
                        
                        Text("Dragon Well Green Tea")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.teaTextPrimaryAlt)
                        
                        Text("Successfully scanned!")
                            .font(.system(size: 14))
                            .foregroundColor(Color.teaTextSecondaryAlt)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            VStack(spacing: 16) {
                Text("How it works:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.teaTextPrimaryAlt)
                
                VStack(alignment: .leading, spacing: 12) {
                    instructionRow(number: "1", text: "Attach QR/NFC tags to tea containers")
                    instructionRow(number: "2", text: "Scan to add tea information")
                    instructionRow(number: "3", text: "Track expiration and brewing details")
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var arPreview: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("AR Tea Explorer")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.teaTextPrimaryAlt)
            
            // AR preview simulation
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 300, height: 200)
                
                if !hasInteracted[2] {
                    Image(systemName: "arkit")
                        .font(.system(size: 60))
                        .foregroundColor(Color.vibrantOrange)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                hasInteracted[2] = true
                            }
                        }
                    
                    Text("Tap to preview AR")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.vibrantOrange)
                        .offset(y: 60)
                } else {
                    // Simulated AR cards
                    HStack(spacing: -30) {
                        ForEach(0..<3) { index in
                            miniARCard(index: index)
                                .scaleEffect(1.0 - Double(index) * 0.1)
                                .offset(x: Double(index) * 20, y: Double(index) * 10)
                                .zIndex(Double(3 - index))
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            VStack(spacing: 16) {
                Text("Point your camera at tea boxes to:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.teaTextPrimaryAlt)
                
                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "eye.fill", text: "See floating info cards")
                    featureRow(icon: "info.circle.fill", text: "View tea details instantly")
                    featureRow(icon: "sparkles", text: "Get AI recommendations")
                }
                .padding(.horizontal, 60)
            }
            
            Spacer()
        }
    }
    
    private var personalizedExperience: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Your Tea Journey")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.teaTextPrimaryAlt)
            
            // Feature cards
            VStack(spacing: 16) {
                personalFeatureCard(
                    icon: "calendar",
                    title: "Daily Recommendations",
                    description: "Get a new tea suggestion every day"
                )
                
                personalFeatureCard(
                    icon: "chart.bar.fill",
                    title: "Track Your Collection",
                    description: "Monitor your tea inventory and preferences"
                )
                
                personalFeatureCard(
                    icon: "heart.fill",
                    title: "Mood-Based Suggestions",
                    description: "Find the perfect tea for how you're feeling"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Permission requests
            VStack(spacing: 12) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color.vibrantGreen)
                
                Text("Your data is private and secure")
                    .font(.system(size: 14))
                    .foregroundColor(Color.teaTextSecondaryAlt)
            }
            
            Spacer()
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentPage > 0 {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentPage -= 1
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.teaTextSecondaryAlt)
                }
            }
            
            Spacer()
            
            if currentPage < 3 {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentPage += 1
                    }
                }) {
                    Text("Next")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.teaPrimaryAlt)
                        )
                }
            } else {
                Button(action: {
                    hasCompletedOnboarding = true
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }) {
                    HStack(spacing: 8) {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.teaPrimaryAlt, Color.vibrantGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
        }
    }
    
    private var interactiveDemoOverlay: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .onTapGesture {
                showInteractiveDemo = false
            }
    }
    
    // Helper views
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color.vibrantGreen)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color.teaTextPrimaryAlt)
            
            Spacer()
        }
    }
    
    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.vibrantBlue))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color.teaTextSecondaryAlt)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func personalFeatureCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.teaPrimaryAlt)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.teaPrimaryAlt.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.teaTextPrimaryAlt)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color.teaTextSecondaryAlt)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        )
    }
    
    private func miniARCard(index: Int) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.white)
            
            Text(["Green Tea", "Black Tea", "Oolong"][index])
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(12)
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.teaPrimaryAlt.opacity(0.5), lineWidth: 1)
                )
        )
    }
    
    private func showScanAnimation() {
        // Simulate scanning animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Animation handled by state change
        }
    }
}

struct InteractiveOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveOnboardingView(hasCompletedOnboarding: .constant(false))
    }
}