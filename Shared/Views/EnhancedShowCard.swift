//
//  EnhancedShowCard.swift
//  TeaElephant
//
//  Enhanced tea info display with beautiful design
//

import SwiftUI
import TeaElephantSchema

struct EnhancedShowCard: View {
    @Binding var info: TeaInfo?
    @State private var showingDetails = false
    
    var body: some View {
        if let info = info {
            ZStack {
                // Liquid glass background
                LiquidBackground(
                    primaryColor: Color.teaPrimaryAlt,
                    secondaryColor: Color.vibrantBlue
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card with glass effect
                        headerCard(info: info)
                        
                        // Details Cards with glass style
                        VStack(spacing: 16) {
                            // Description Card
                            if !info.data.description.isEmpty {
                                detailCard(
                                    title: "Description",
                                    icon: "text.alignleft",
                                    color: Color.teaPrimaryAlt
                                ) {
                                    Text(info.data.description)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.teaTextPrimaryAlt)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            
                            // Brewing Instructions Card
                            detailCard(
                                title: "Brewing Instructions",
                                icon: "thermometer",
                                color: Color.vibrantOrange
                            ) {
                                VStack(spacing: 12) {
                                    brewingRow(
                                        icon: "thermometer",
                                        label: "Temperature",
                                        value: "\(info.meta.brewingTemp)°C"
                                    )
                                    
                                    brewingRow(
                                        icon: "calendar",
                                        label: "Use Until",
                                        value: dateToString(info.meta.expirationDate),
                                        isWarning: isExpired(info.meta.expirationDate)
                                    )
                                }
                            }
                            
                            // Tags Card
                            if !info.tags.isEmpty {
                                detailCard(
                                    title: "Tags",
                                    icon: "tag.fill",
                                    color: Color.vibrantGreen
                                ) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(info.tags, id: \.self.id) { tag in
                                            tagRow(tag: tag)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 20)
                }
            }
        } else {
            emptyStateView
        }
    }
    
    // MARK: - Header Card
    private func headerCard(info: TeaInfo) -> some View {
        VStack(spacing: 16) {
            // Tea Icon with glass effect
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
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
                    .shadow(color: Color.teaPrimaryAlt.opacity(0.2), radius: 10, y: 4)
                
                Image(systemName: teaIcon(for: info.data.type.value ?? .unknown))
                    .font(.system(size: 48))
                    .foregroundColor(Color.teaPrimaryAlt)
                    .shadow(color: Color.teaPrimaryAlt.opacity(0.3), radius: 2)
            }
            
            // Tea Name with glass text effect
            Text(info.data.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.teaTextPrimaryAlt)
                .multilineTextAlignment(.center)
                .shadow(color: Color.glassShadow, radius: 1)
            
            // Tea Type Badge with glass style
            Text(teaTypeLabel(info.data.type.value ?? .unknown))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.teaPrimaryAlt)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.glassBorder, lineWidth: 1)
                        )
                )
                .shadow(color: Color.glassShadow, radius: 4, y: 2)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Detail Card
    private func detailCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.3), radius: 1)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.teaTextPrimaryAlt)
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .glassStyle()
    }
    
    // MARK: - Brewing Row
    private func brewingRow(icon: String, label: String, value: String, isWarning: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.teaTextSecondaryAlt)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Color.teaTextSecondaryAlt)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isWarning ? Color(red: 0.85, green: 0.35, blue: 0.35) : Color.teaTextPrimaryAlt)
        }
    }
    
    // MARK: - Tag Row
    private func tagRow(tag: Tag) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: tag.color))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.glassBorder.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color(hex: tag.color).opacity(0.3), radius: 2)
            
            Text("\(tag.category)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.teaTextSecondaryAlt)
            
            Text(tag.name)
                .font(.system(size: 14))
                .foregroundColor(Color.teaTextPrimaryAlt)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        ZStack {
            // Liquid glass background for empty state
            LiquidBackground(
                primaryColor: Color.teaPrimaryAlt.opacity(0.3),
                secondaryColor: Color.vibrantBlue.opacity(0.2)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon with glass effect
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.glassBorder, lineWidth: 1)
                        )
                        .shadow(color: Color.glassShadow, radius: 10, y: 4)
                    
                    Image(systemName: "leaf.circle")
                        .font(.system(size: 60))
                        .foregroundColor(Color.teaPrimaryAlt.opacity(0.6))
                }
                
                VStack(spacing: 8) {
                    Text("No Tea Selected")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.teaTextPrimaryAlt)
                        .shadow(color: Color.glassShadow, radius: 1)
                    
                    Text("Scan a tag to view tea information")
                        .font(.system(size: 16))
                        .foregroundColor(Color.teaTextSecondaryAlt)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func teaIcon(for type: Type_Enum) -> String {
        switch type {
        case .tea:
            return "leaf.fill"
        case .coffee:
            return "cup.and.saucer.fill"
        case .herb:
            return "leaf.arrow.circlepath"
        default:
            return "leaf"
        }
    }
    
    private func teaTypeLabel(_ type: Type_Enum) -> String {
        switch type {
        case .tea:
            return "Traditional Tea"
        case .coffee:
            return "Coffee"
        case .herb:
            return "Herbal Tea"
        case .other:
            return "Other"
        case .unknown:
            return "Unknown Type"
        }
    }
    
    private func dateToString(_ date: Foundation.Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func isExpired(_ date: Foundation.Date) -> Bool {
        return date < Date()
    }
}

struct EnhancedShowCard_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedShowCard(info: .constant(nil))
    }
}