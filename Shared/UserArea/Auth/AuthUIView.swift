//
//  AuthUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 13/08/2023.
//

import SwiftUI
import AuthenticationServices

struct AuthUIView: View {
    @State private var showingBenefits = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Liquid glass background
            LiquidBackground(
                primaryColor: Color.teaPrimaryAlt,
                secondaryColor: Color.vibrantBlue
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)
                    
                    // App branding
                    VStack(spacing: 24) {
                        // Logo with glass effect
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
                                .frame(width: 120, height: 120)
                                .blur(radius: 30)
                            
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color.teaPrimaryAlt)
                                .symbolEffect(.pulse.byLayer, options: .repeating, value: true)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Welcome to TeaElephant")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color.teaTextPrimaryAlt)
                                .multilineTextAlignment(.center)
                            
                            Text("Sign in to unlock your personal tea journey")
                                .font(.system(size: 18))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    
                    // Benefits section
                    VStack(spacing: 20) {
                        benefitCard(
                            icon: "cloud.fill",
                            title: "Sync Across Devices",
                            description: "Access your tea collection anywhere"
                        )
                        
                        benefitCard(
                            icon: "heart.fill",
                            title: "Personalized Recommendations",
                            description: "Get tea suggestions based on your preferences"
                        )
                        
                        benefitCard(
                            icon: "chart.bar.fill",
                            title: "Track Your Collection",
                            description: "Monitor your tea inventory and tasting history"
                        )
                        
                        benefitCard(
                            icon: "sparkles",
                            title: "AI-Powered Insights",
                            description: "Discover new teas with smart recommendations"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Sign in button section
                    VStack(spacing: 20) {
                        // Custom wrapper for Sign in with Apple button
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName]
                            },
                            onCompletion: { response in
                                switch response {
                                case .success(let authResults):
                                    guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential,
                                          let code = credentials.authorizationCode,
                                          let codeString = String(data: code, encoding: .utf8) else { return }
                                    Task {
                                        await AuthManager.shared.Auth(codeString)
                                    }
                                case .failure(let error):
                                    print("Authentication error: \(error.localizedDescription)")
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 50)
                        .frame(maxWidth: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                        
                        // Privacy note
                        VStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.vibrantGreen.opacity(0.8))
                            
                            Text("Your data is private and secure")
                                .font(.system(size: 13))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                            
                            Text("We never share your information")
                                .font(.system(size: 11))
                                .foregroundColor(Color.teaTextSecondaryAlt.opacity(0.8))
                        }
                        .padding(.top, 8)
                    }
                    
                    // Skip option
                    Button(action: {
                        // Dismiss to go back to menu
                        dismiss()
                    }) {
                        Text("Browse without signing in")
                            .font(.system(size: 14))
                            .foregroundColor(Color.teaTextSecondaryAlt)
                            .underline()
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
    
    private func benefitCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            // Icon with glass effect
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.glassBorder,
                                        Color.teaPrimaryAlt.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color.teaPrimaryAlt)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.teaTextPrimaryAlt)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color.teaTextSecondaryAlt)
                    .fixedSize(horizontal: false, vertical: true)
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
}

struct AuthUIView_Previews: PreviewProvider {
    static var previews: some View {
        AuthUIView()
    }
}
