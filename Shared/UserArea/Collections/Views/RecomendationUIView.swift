//
//  RecomendationUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 01/09/2023.
//

import SwiftUI
import TeaElephantSchema

struct RecomendationUIView: View {
    var id: String
    @ObservedObject var manager: CollectionsManager
    @State private var feelings = ""
    @State private var type = Type_Enum.unknown
    @State private var withAdditives = true
    @State private var isTyping = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.teaBackgroundAlt,
                    Color.teaPrimaryAlt.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundColor(Color.vibrantBlue)
                            Text("AI Tea Recommendations")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color.teaTextPrimaryAlt)
                        }
                        
                        Text("Tell me how you're feeling and I'll find the perfect tea for you")
                            .font(.system(size: 14))
                            .foregroundColor(Color.teaTextSecondaryAlt)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Filter Options Card
                    VStack(spacing: 20) {
                        // Type Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Tea Type", systemImage: "leaf.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach([
                                        (Type_Enum.unknown, "Any", "sparkles"),
                                        (Type_Enum.tea, "Tea", "leaf.fill"),
                                        (Type_Enum.coffee, "Coffee", "cup.and.saucer.fill"),
                                        (Type_Enum.herb, "Herb", "leaf.arrow.circlepath")
                                    ], id: \.0) { value, label, icon in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                type = value
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: icon)
                                                    .font(.system(size: 14))
                                                Text(label)
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .foregroundColor(type == value ? .white : Color.teaTextPrimaryAlt)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background {
                                                if type == value {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.teaPrimaryAlt)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(.ultraThinMaterial)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(Color.glassBorder, lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }
                                        .buttonStyle(ScaledButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        // Additives Toggle
                        HStack {
                            Label("Include Additives", systemImage: "plus.circle")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                            
                            Spacer()
                            
                            Toggle("", isOn: $withAdditives)
                                .tint(Color.teaPrimaryAlt)
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Feelings Input Card
                    VStack(spacing: 16) {
                        Label("How are you feeling?", systemImage: "heart.text.square")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.teaTextSecondaryAlt)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            TextField("Relaxed, energetic, focused...", text: $feelings)
                                .textFieldStyle(EnhancedTextFieldStyle(isValid: true))
                                .focused($isFocused)
                                .onTapGesture {
                                    isTyping = true
                                }
                                .onChange(of: feelings) { _, _ in
                                    isTyping = !feelings.isEmpty
                                }
                            
                            Button(action: {
                                isFocused = false
                                Task {
                                    manager.recomendation(id, feelings: feelings)
                                }
                            }) {
                                Image(systemName: "sparkles.rectangle.stack.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.vibrantBlue,
                                                        Color.teaPrimaryAlt
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                            }
                            .buttonStyle(ScaledButtonStyle())
                            .disabled(feelings.isEmpty || manager.recomendationLoading)
                            .opacity(feelings.isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Results Section
                    if manager.recomendationLoading {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .stroke(Color.glassBorder, lineWidth: 3)
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: 0.6)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.vibrantBlue, Color.teaPrimaryAlt],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                    .animation(
                                        .linear(duration: 1)
                                        .repeatForever(autoreverses: false),
                                        value: manager.recomendationLoading
                                    )
                            }
                            
                            Text("AI is crafting your perfect recommendation...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    } else if let text = manager.lastRecomendation {
                        VStack(spacing: 20) {
                            // Recommendation Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.vibrantBlue)
                                    Text("Your Recommendation")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.teaTextPrimaryAlt)
                                }
                                
                                Text(LocalizedStringKey(text))
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.teaTextPrimaryAlt)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.teaPrimaryAlt.opacity(0.1),
                                                Color.vibrantBlue.opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.teaPrimaryAlt.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 20)
                            
                            // Try Another Button
                            Button(action: {
                                Task {
                                    manager.anotherRecomendation(id)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Try Another")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(Color.teaPrimaryAlt)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.teaPrimaryAlt.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                            .buttonStyle(ScaledButtonStyle())
                            .disabled(manager.recomendationLoading)
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        RecomendationUIView(id: "", manager: CollectionsManager())
    }
}
