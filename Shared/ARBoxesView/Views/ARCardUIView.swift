//
//  TitleUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10/08/2023.
//

import Foundation
import SwiftUI
import ApolloAPI
import TeaElephantSchema

struct ARCardUIView: View {
    @EnvironmentObject private var detailController: DetailManager
    var info: TeaInfo
    @State private var isHovered = false
    
    var body: some View {
        GeometryReader { geometry in
            let iconSize = min(geometry.size.width, geometry.size.height) * 0.2 // Icon is 20% of card size
            let fontSize = iconSize * 0.5 // Font is 50% of icon size
            
            Button(action: {
                detailController.info = info
            }) {
                VStack(spacing: 8) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(typeColor(for: info.data.type).opacity(0.2))
                            .frame(width: iconSize, height: iconSize)
                            .overlay(
                                Circle()
                                    .stroke(typeColor(for: info.data.type).opacity(0.4), lineWidth: 0.5)
                            )
                        
                        Image(systemName: iconForType(info.data.type))
                            .font(.system(size: fontSize))
                            .foregroundColor(typeColor(for: info.data.type))
                    }
                
                    // Tea name
                    Text(info.data.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    // Type label
                    Text(typeShortLabel(for: info.data.type))
                        .font(.system(size: 11))
                        .foregroundColor(typeColor(for: info.data.type))
                    
                    // Expiration if expired
                    if isExpired(info.meta.expirationDate) {
                        Text(shortDateString(info.meta.expirationDate))
                            .font(.system(size: 10))
                            .foregroundColor(.red.opacity(0.9))
                    }
                    
                    // Tags dots
                    if !info.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(info.tags.prefix(3), id: \.self.id) { tag in
                                Circle()
                                    .fill(Color(hex: tag.color))
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow dynamic sizing
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(typeColor(for: info.data.type).opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
                )
                .scaleEffect(isHovered ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            }
            .buttonStyle(ARCardButtonStyle())
            .onHover { hovering in
                isHovered = hovering
            }
        }
    }
    
    private func shortDateString(_ date: Foundation.Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func isExpired(_ date: Foundation.Date) -> Bool {
        return date < Foundation.Date()
    }
    
    private func typeColor(for type: GraphQLEnum<Type_Enum>?) -> Color {
        guard let type = type else { return Color.gray }
        
        switch type {
        case .tea:
            return Color.teaPrimaryAlt
        case .coffee:
            return Color.teaSecondaryAlt
        case .herb:
            return Color.vibrantGreen
        case .other:
            return Color.gray
        default:
            return Color.gray
        }
    }
    
    private func iconForType(_ type: GraphQLEnum<Type_Enum>?) -> String {
        guard let type = type else { return "questionmark.circle" }
        
        switch type {
        case .tea:
            return "leaf.fill"
        case .coffee:
            return "cup.and.saucer.fill"
        case .herb:
            return "leaf.arrow.circlepath"
        case .other:
            return "questionmark.circle"
        default:
            return "questionmark.circle"
        }
    }
    
    private func typeLabel(for type: GraphQLEnum<Type_Enum>?) -> String {
        guard let type = type else { return "Other" }
        
        switch type {
        case .tea:
            return "Traditional Tea"
        case .coffee:
            return "Coffee"
        case .herb:
            return "Herbal Infusion"
        case .other:
            return "Other"
        default:
            return "Other"
        }
    }
    
    private func typeShortLabel(for type: GraphQLEnum<Type_Enum>?) -> String {
        guard let type = type else { return "Other" }
        
        switch type {
        case .tea:
            return "Traditional"
        case .coffee:
            return "Coffee"
        case .herb:
            return "Herbal"
        case .other:
            return "Other"
        default:
            return "Other"
        }
    }
}

// Custom button style for AR cards
struct ARCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


struct ARCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.tea), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}

struct ARCard_Herb: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.herb), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}

struct ARCard_Coffee: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.coffee), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}

struct ARCard_Other: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.other), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}
