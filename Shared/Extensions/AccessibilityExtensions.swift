//
//  AccessibilityExtensions.swift
//  TeaElephant
//
//  Accessibility extensions for better VoiceOver and Dynamic Type support
//

import SwiftUI

// MARK: - Dynamic Type Extensions
extension View {
    /// Apply dynamic type with a specific range
    func dynamicText(_ sizeCategory: DynamicTypeSize = .large) -> some View {
        self.dynamicTypeSize(.xSmall ... .accessibility3)
    }
    
    /// Scale value based on dynamic type settings
    func scaledValue(_ baseValue: CGFloat, for textStyle: Font.TextStyle = .body) -> CGFloat {
        UIFontMetrics(forTextStyle: UIFont.TextStyle(textStyle)).scaledValue(for: baseValue)
    }
}

// MARK: - VoiceOver Extensions
extension View {
    /// Add comprehensive accessibility traits
    func accessibilityElement(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Mark as a container for better VoiceOver navigation
    func accessibilityContainer() -> some View {
        self.accessibilityElement(children: .contain)
    }
    
    /// Combine elements for better VoiceOver experience
    func accessibilityCombine() -> some View {
        self.accessibilityElement(children: .combine)
    }
}

// MARK: - Semantic Colors for Accessibility
extension Color {
    /// High contrast variants for accessibility
    static var accessibleGreen: Color {
        Color(UIColor { traitCollection in
            traitCollection.accessibilityContrast == .high
                ? UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
                : UIColor(red: 0.55, green: 0.71, blue: 0.55, alpha: 1.0)
        })
    }
    
    static var accessibleBrown: Color {
        Color(UIColor { traitCollection in
            traitCollection.accessibilityContrast == .high
                ? UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
                : UIColor(red: 0.55, green: 0.43, blue: 0.31, alpha: 1.0)
        })
    }
}

// MARK: - Reduce Motion Support
struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation?
    let reducedAnimation: Animation?
    
    func body(content: Content) -> some View {
        content.animation(reduceMotion ? reducedAnimation : animation)
    }
}

extension View {
    func accessibilityAnimation(_ animation: Animation?, reduced: Animation? = .easeInOut(duration: 0.1)) -> some View {
        self.modifier(ReducedMotionModifier(animation: animation, reducedAnimation: reduced))
    }
}

// MARK: - UIFont.TextStyle Extension
extension UIFont.TextStyle {
    init(_ textStyle: Font.TextStyle) {
        switch textStyle {
        case .largeTitle:
            self = .largeTitle
        case .title:
            self = .title1
        case .title2:
            self = .title2
        case .title3:
            self = .title3
        case .headline:
            self = .headline
        case .body:
            self = .body
        case .callout:
            self = .callout
        case .subheadline:
            self = .subheadline
        case .footnote:
            self = .footnote
        case .caption:
            self = .caption1
        case .caption2:
            self = .caption2
        @unknown default:
            self = .body
        }
    }
}