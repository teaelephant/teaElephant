//
//  HapticFeedback.swift
//  TeaElephant
//
//  Haptic feedback utilities for better user experience
//

import SwiftUI
import UIKit

@MainActor
enum HapticFeedback {
    
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.error)
    }
    
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
    }
}

// MARK: - View Extension for Haptic Feedback
extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light, trigger: @escaping () -> Bool) -> some View {
        self.onChange(of: trigger()) { _, newValue in
            if newValue {
                switch style {
                case .light:
                    HapticFeedback.light()
                case .medium:
                    HapticFeedback.medium()
                case .heavy:
                    HapticFeedback.heavy()
                default:
                    HapticFeedback.light()
                }
            }
        }
    }
}
