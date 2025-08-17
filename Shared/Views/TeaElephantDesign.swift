//
//  TeaElephantDesign.swift (Views)
//  TeaElephant
//
//  Liquid Glass (Glassmorphism) Design System
//  This file provides the design system components with a modern glass aesthetic
//

import SwiftUI

// MARK: - Core Colors with Dark Mode Support
extension Color {
    // Original tea-inspired colors with dark mode adaptation
    static let teaPrimaryAlt = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.65, green: 0.81, blue: 0.65, alpha: 1.0) // Lighter green for dark mode
            : UIColor(red: 0.55, green: 0.71, blue: 0.55, alpha: 1.0) // Sage Green
    })
    
    static let teaSecondaryAlt = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.75, green: 0.63, blue: 0.51, alpha: 1.0) // Lighter brown for dark mode
            : UIColor(red: 0.55, green: 0.43, blue: 0.31, alpha: 1.0) // Warm Brown
    })
    
    static let teaAccentAlt = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.55, green: 0.71, blue: 0.55, alpha: 1.0) // Lighter for dark mode
            : UIColor(red: 0.35, green: 0.51, blue: 0.35, alpha: 1.0) // Deep Green
    })
    
    static let teaBackgroundAlt = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0) // Dark background
            : UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1.0) // Soft Cream
    })
    
    static let teaCardBackgroundAlt = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0) // Dark card
            : UIColor.white
    })
    
    static let teaTextPrimaryAlt = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light text for dark mode
            : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    })
    
    static let teaTextSecondaryAlt = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) // Lighter secondary for dark mode
            : UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    })
    
    // Vibrant accent colors (adjusted for better visibility in both modes)
    static let vibrantPink = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.2, blue: 0.6, alpha: 1.0)
    })
    
    static let vibrantBlue = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
            : UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
    })
    
    static let vibrantPurple = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 1.0)
            : UIColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 1.0)
    })
    
    static let vibrantOrange = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    })
    
    static let vibrantGreen = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)
            : UIColor(red: 0.2, green: 0.75, blue: 0.3, alpha: 1.0)
    })
    
    // Semi-transparent colors for glass effects (adaptive)
    static let glassFill = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.1) // Less opacity in dark mode
            : UIColor.white.withAlphaComponent(0.2)
    })
    
    static let glassBorder = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.2) // Less bright in dark mode
            : UIColor.white.withAlphaComponent(0.4)
    })
    
    static let glassOverlay = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.05)
            : UIColor.white.withAlphaComponent(0.1)
    })
    
    static let glassShadow = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.3) // Stronger shadows in dark mode
            : UIColor.black.withAlphaComponent(0.15)
    })
}

// MARK: - Typography with Glass-optimized Styles
struct TeaTypographyAlt {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let callout = Font.system(size: 14, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Text Modifiers for Glass Surfaces
extension View {
    func glassTextStyle(color: Color = .primary) -> some View {
        self
            .foregroundColor(color)
            .modifier(AdaptiveTextShadow())
    }
    
    func vibrantTextStyle(color: Color) -> some View {
        self
            .foregroundColor(color)
            .shadow(color: color.opacity(0.5), radius: 2, x: 0, y: 0)
    }
}

// Adaptive text shadow that changes based on color scheme
struct AdaptiveTextShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            // In dark mode, use a subtle glow effect
            content
                .shadow(color: .white.opacity(0.1), radius: 0.5, x: 0, y: 0.5)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
        } else {
            // In light mode, use the original shadow
            content
                .shadow(color: .white.opacity(0.5), radius: 0, x: 0, y: 1)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: -1)
        }
    }
}

// MARK: - Spacing (Alternative naming)
struct TeaSpacingAlt {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
    static let xxLarge: CGFloat = 48
}

// MARK: - Corner Radius (Alternative naming)
struct TeaCornerRadiusAlt {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24
}

// MARK: - Shadows (Alternative naming)
struct TeaShadowAlt {
    struct ShadowStyleAlt {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    static let light = ShadowStyleAlt(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let medium = ShadowStyleAlt(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let heavy = ShadowStyleAlt(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
}

// MARK: - Custom Button Styles with Glass Effect
struct TeaPrimaryButtonStyleAlt: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TeaTypographyAlt.headline)
            .foregroundColor(.white)
            .padding(.horizontal, TeaSpacingAlt.large)
            .padding(.vertical, TeaSpacingAlt.medium)
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: isEnabled ? [
                            Color.teaPrimaryAlt,
                            Color.teaPrimaryAlt.opacity(0.8)
                        ] : [Color.gray, Color.gray.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle glass overlay
                    Color.white.opacity(0.1)
                        .background(.ultraThinMaterial.opacity(0.3))
                }
            )
            .cornerRadius(TeaCornerRadiusAlt.medium)
            .shadow(color: isEnabled ? Color.teaPrimaryAlt.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct TeaSecondaryButtonStyleAlt: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TeaTypographyAlt.headline)
            .foregroundColor(.teaPrimaryAlt)
            .padding(.horizontal, TeaSpacingAlt.large)
            .padding(.vertical, TeaSpacingAlt.medium)
            .background(
                ZStack {
                    // Glass background
                    Color.clear.background(.ultraThinMaterial)
                    
                    // Subtle color tint
                    Color.teaPrimaryAlt.opacity(0.05)
                }
            )
            .cornerRadius(TeaCornerRadiusAlt.medium)
            .overlay(
                RoundedRectangle(cornerRadius: TeaCornerRadiusAlt.medium)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.teaPrimaryAlt.opacity(0.8),
                                Color.teaPrimaryAlt.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.glassShadow.opacity(0.5), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Floating Glass Button Style
struct FloatingGlassButtonStyle: ButtonStyle {
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TeaTypographyAlt.headline)
            .foregroundColor(.white)
            .padding(.horizontal, TeaSpacingAlt.large)
            .padding(.vertical, TeaSpacingAlt.medium)
            .background(
                ZStack {
                    // Vibrant gradient
                    LinearGradient(
                        colors: [
                            accentColor,
                            accentColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Glass overlay
                    Color.white.opacity(0.2)
                        .background(.ultraThinMaterial.opacity(0.5))
                }
            )
            .cornerRadius(TeaCornerRadiusAlt.xLarge)
            .overlay(
                RoundedRectangle(cornerRadius: TeaCornerRadiusAlt.xLarge)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func floatingGlassButton(_ color: Color) -> some View {
        self.buttonStyle(FloatingGlassButtonStyle(accentColor: color))
    }
}

// MARK: - Glass View Modifier
struct GlassViewModifier: ViewModifier {
    var cornerRadius: CGFloat = TeaCornerRadiusAlt.large
    var borderWidth: CGFloat = 1
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.glassBorder, lineWidth: borderWidth)
            )
            .shadow(color: Color.glassShadow, radius: 8, x: 0, y: 4)
    }
}

extension View {
    func glassStyle(cornerRadius: CGFloat = TeaCornerRadiusAlt.large, borderWidth: CGFloat = 1) -> some View {
        self.modifier(GlassViewModifier(cornerRadius: cornerRadius, borderWidth: borderWidth))
    }
}

// MARK: - Card Styles
struct TeaCardStyleAlt: ViewModifier {
    func body(content: Content) -> some View {
        content
            .glassStyle()
    }
}

// MARK: - Glass Card Style with custom colors
struct ColoredGlassCard: ViewModifier {
    let accentColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: [
                            accentColor.opacity(0.1),
                            accentColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Glass material overlay
                    Color.clear.background(.ultraThinMaterial)
                }
            )
            .cornerRadius(TeaCornerRadiusAlt.large)
            .overlay(
                RoundedRectangle(cornerRadius: TeaCornerRadiusAlt.large)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.glassBorder,
                                accentColor.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: accentColor.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func teaCardStyleAlt() -> some View {
        self.modifier(TeaCardStyleAlt())
    }
    
    func coloredGlassCard(_ color: Color) -> some View {
        self.modifier(ColoredGlassCard(accentColor: color))
    }
}

// MARK: - Animated Gradient Backgrounds
struct AnimatedGradientBackground: View {
    let colors: [Color]
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Liquid Background Effect with Dark Mode Support
struct LiquidBackground: View {
    let primaryColor: Color
    let secondaryColor: Color
    
    @Environment(\.colorScheme) var colorScheme
    @State private var offset1 = CGSize.zero
    @State private var offset2 = CGSize.zero
    
    private var baseOpacity: Double {
        colorScheme == .dark ? 0.3 : 0.6
    }
    
    private var blobOpacity: Double {
        colorScheme == .dark ? 0.2 : 0.5
    }
    
    var body: some View {
        ZStack {
            // Base color for dark mode
            if colorScheme == .dark {
                Color.black
            }
            
            // Base gradient
            LinearGradient(
                colors: [
                    primaryColor.opacity(baseOpacity),
                    secondaryColor.opacity(baseOpacity * 0.67)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Floating blob 1
            Circle()
                .fill(primaryColor.opacity(blobOpacity))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(offset1)
                .onAppear {
                    withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                        offset1 = CGSize(width: 100, height: 150)
                    }
                }
            
            // Floating blob 2
            Circle()
                .fill(secondaryColor.opacity(blobOpacity))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(offset2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                        offset2 = CGSize(width: -100, height: -120)
                    }
                }
            
            // Glass overlay - lighter in dark mode
            if colorScheme == .dark {
                Color.clear.background(.ultraThinMaterial.opacity(0.5))
            } else {
                Color.clear.background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass Loading View
struct GlassLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: TeaSpacingAlt.medium) {
            ZStack {
                Circle()
                    .stroke(Color.glassBorder, lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(
                        LinearGradient(
                            colors: [Color.teaPrimaryAlt, Color.vibrantBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text("Loading...")
                .font(TeaTypographyAlt.callout)
                .glassTextStyle()
        }
        .padding(TeaSpacingAlt.large)
        .glassStyle()
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Glass Empty State View
struct GlassEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: TeaSpacingAlt.large) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0.2),
                                accentColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .vibrantTextStyle(color: accentColor)
            }
            
            VStack(spacing: TeaSpacingAlt.small) {
                Text(title)
                    .font(TeaTypographyAlt.title)
                    .glassTextStyle()
                
                Text(message)
                    .font(TeaTypographyAlt.body)
                    .glassTextStyle(color: .secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(TeaSpacingAlt.xLarge)
        .frame(maxWidth: .infinity)
        .coloredGlassCard(accentColor)
    }
}