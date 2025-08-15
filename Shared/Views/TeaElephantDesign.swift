//
//  TeaElephantDesign.swift
//  TeaElephant
//
//  Design System for consistent UI across the app
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary Colors - Tea inspired
    static let teaGreen = Color(red: 0.55, green: 0.71, blue: 0.55)
    static let teaDarkGreen = Color(red: 0.35, green: 0.51, blue: 0.35)
    static let teaBrown = Color(red: 0.55, green: 0.43, blue: 0.31)
    static let teaCream = Color(red: 0.96, green: 0.94, blue: 0.89)
    
    // Semantic Colors
    static let teaPrimary = teaGreen
    static let teaSecondary = teaBrown
    static let teaBackground = teaCream
    static let teaAccent = teaDarkGreen
    
    // System overrides
    static let teaError = Color(red: 0.85, green: 0.35, blue: 0.35)
    static let teaWarning = Color(red: 0.95, green: 0.65, blue: 0.25)
    static let teaSuccess = teaGreen
}

// MARK: - Typography
struct TeaTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Spacing
struct TeaSpacing {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
    static let xxLarge: CGFloat = 48
}

// MARK: - Corner Radius
struct TeaCorners {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24
}

// MARK: - Shadows
struct TeaShadow {
    static let light = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let heavy = Shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
}

// MARK: - Custom Button Styles
struct TeaPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TeaTypography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, TeaSpacing.large)
            .padding(.vertical, TeaSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: TeaCorners.medium)
                    .fill(isEnabled ? Color.teaPrimary : Color.gray)
                    .shadow(color: .black.opacity(0.1), radius: configuration.isPressed ? 2 : 4, y: configuration.isPressed ? 1 : 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct TeaSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TeaTypography.headline)
            .foregroundColor(.teaPrimary)
            .padding(.horizontal, TeaSpacing.large)
            .padding(.vertical, TeaSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: TeaCorners.medium)
                    .stroke(Color.teaPrimary, lineWidth: 2)
                    .background(Color.white)
                    .cornerRadius(TeaCorners.medium)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Card View Modifier
struct TeaCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(TeaSpacing.medium)
            .background(Color.white)
            .cornerRadius(TeaCorners.medium)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

extension View {
    func teaCardStyle() -> some View {
        self.modifier(TeaCardStyle())
    }
}

// MARK: - Collection Card View
struct TeaCollectionCard: View {
    let name: String
    let itemCount: Int
    let lastUpdated: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: TeaSpacing.xSmall) {
            HStack {
                Image(systemName: "leaf.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.teaPrimary)
                
                Spacer()
                
                Text("\(itemCount)")
                    .font(TeaTypography.title2)
                    .foregroundColor(.teaSecondary)
                Text("teas")
                    .font(TeaTypography.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(name)
                .font(TeaTypography.headline)
                .foregroundColor(.primary)
            
            if let lastUpdated = lastUpdated {
                Text("Updated \(lastUpdated, style: .relative)")
                    .font(TeaTypography.caption)
                    .foregroundColor(.secondary)
            }
        }
        .teaCardStyle()
    }
}

// MARK: - Loading View
struct TeaLoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: TeaSpacing.medium) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.teaPrimary)
            Text(message)
                .font(TeaTypography.callout)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.teaBackground.opacity(0.3))
    }
}

// MARK: - Empty State View
struct TeaEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: TeaSpacing.large) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.teaPrimary.opacity(0.7))
            
            Text(title)
                .font(TeaTypography.title2)
                .foregroundColor(.primary)
            
            Text(message)
                .font(TeaTypography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TeaSpacing.xLarge)
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(TeaPrimaryButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.teaBackground.opacity(0.3))
    }
}