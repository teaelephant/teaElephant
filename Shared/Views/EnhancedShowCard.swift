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
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard(info: info)
                    
                    // Details Cards
                    VStack(spacing: 16) {
                        // Description Card
                        if !info.data.description.isEmpty {
                            detailCard(
                                title: "Description",
                                icon: "text.alignleft",
                                color: Color(red: 0.55, green: 0.71, blue: 0.55)
                            ) {
                                Text(info.data.description)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        // Brewing Instructions Card
                        detailCard(
                            title: "Brewing Instructions",
                            icon: "thermometer",
                            color: Color(red: 0.55, green: 0.43, blue: 0.31)
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
                        if #available(iOS 17.0, *), !info.tags.isEmpty {
                            detailCard(
                                title: "Tags",
                                icon: "tag.fill",
                                color: Color(red: 0.35, green: 0.51, blue: 0.35)
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
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.94, blue: 0.89),
                        Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        } else {
            emptyStateView
        }
    }
    
    // MARK: - Header Card
    private func headerCard(info: TeaInfo) -> some View {
        VStack(spacing: 16) {
            // Tea Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.3),
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: teaIcon(for: info.data.type.value ?? .unknown))
                    .font(.system(size: 48))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
            }
            
            // Tea Name
            Text(info.data.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Tea Type Badge
            Text(teaTypeLabel(info.data.type.value ?? .unknown))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.15))
                )
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
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        )
    }
    
    // MARK: - Brewing Row
    private func brewingRow(icon: String, label: String, value: String, isWarning: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isWarning ? Color(red: 0.85, green: 0.35, blue: 0.35) : .primary)
        }
    }
    
    // MARK: - Tag Row
    private func tagRow(tag: TagEntity) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: tag.color))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
            
            Text("\(tag.category)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(tag.name)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Tea Selected")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Scan a tag to view tea information")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.94, blue: 0.89),
                    Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
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