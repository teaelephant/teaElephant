//
//  UserAreaUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 13/08/2023.
//

import SwiftUI

struct UserAreaUIView: View {
    @StateObject private var manager = CollectionsManager()
    @ObservedObject var authManager: AuthManager
    @State private var animationAmount = 1.0
    @State private var hasCheckedAuth = false
    
    var body: some View {
        Group {
            if authManager.loading {
                // Enhanced loading state with liquid glass design
                ZStack {
                    // Liquid glass background
                    LiquidBackground(
                        primaryColor: Color.teaPrimaryAlt,
                        secondaryColor: Color.vibrantBlue
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        // Animated loading indicator
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
                                .frame(width: 80, height: 80)
                                .blur(radius: 20)
                                .scaleEffect(animationAmount)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true),
                                    value: animationAmount
                                )
                            
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.teaPrimaryAlt)
                                .symbolEffect(.pulse.byLayer, options: .repeating, value: true)
                        }
                        
                        VStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.teaPrimaryAlt))
                                .scaleEffect(1.2)
                            
                            Text("Checking authentication...")
                                .font(.system(size: 16))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                        }
                        .padding(24)
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
            } else if authManager.auth {
                CollectionsUIView(manager: manager)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .id(authManager.auth) // Force view recreation when auth changes
            } else {
                AuthUIView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            if !hasCheckedAuth {
                animationAmount = 1.2
                hasCheckedAuth = true
                Task {
                    await authManager.authorized()
                }
            }
        }
    }
}

struct UserAreaUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserAreaUIView(authManager: AuthManager.shared)
    }
}
