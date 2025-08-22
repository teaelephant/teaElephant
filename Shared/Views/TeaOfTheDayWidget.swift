//
//  TeaOfTheDayWidget.swift
//  TeaElephant
//
//  A widget that suggests a tea from your collection to try each day
//

import SwiftUI
import TeaElephantSchema

struct TeaOfTheDayWidget: View {
    @ObservedObject var manager: CollectionsManager
    @State private var todaysTea: TeaInfo?
    @State private var isLoading = true
    @State private var showDetails = false
    @State private var isFromBackend = false
    @AppStorage("lastTeaOfTheDayDate") private var lastTeaDate = ""
    @AppStorage("lastTeaOfTheDayID") private var lastTeaID = ""
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                loadingView
            } else if let tea = todaysTea {
                teaCard(tea)
            } else {
                emptyStateView
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 24)
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
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .onAppear {
            loadTeaOfTheDay()
        }
        .sheet(isPresented: $showDetails) {
            if let tea = todaysTea {
                NavigationView {
                    EnhancedShowCard(info: .constant(tea))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showDetails = false
                                }
                                .foregroundColor(Color.teaAccentAlt)
                            }
                        }
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Finding your tea of the day...")
                .font(.system(size: 14))
                .foregroundColor(Color.teaTextSecondaryAlt)
        }
        .padding(.vertical, 40)
    }
    
    private func teaCard(_ tea: TeaInfo) -> some View {
        Button(action: { showDetails = true }) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: isFromBackend ? "sparkles" : "shuffle")
                                .font(.system(size: 14))
                                .foregroundColor(isFromBackend ? Color.vibrantBlue : Color.teaPrimaryAlt)
                            Text(isFromBackend ? "TEA OF THE DAY" : "RANDOM SELECTION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                                .tracking(1.2)
                        }
                        
                        Text(formattedDate())
                            .font(.system(size: 12))
                            .foregroundColor(Color.teaTextSecondaryAlt.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Refresh button
                    Button(action: { refreshTeaOfTheDay() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.teaPrimaryAlt)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.teaPrimaryAlt.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Tea Info
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(typeColor(for: tea.data.type).opacity(0.15))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(typeColor(for: tea.data.type).opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: iconForType(tea.data.type))
                            .font(.system(size: 28))
                            .foregroundColor(typeColor(for: tea.data.type))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(tea.data.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.teaTextPrimaryAlt)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            // Type
                            Label(typeLabel(for: tea.data.type), systemImage: "leaf.fill")
                                .font(.system(size: 12))
                                .foregroundColor(typeColor(for: tea.data.type))
                            
                            // Brewing temp
                            Label("\(tea.meta.brewingTemp)°C", systemImage: "thermometer")
                                .font(.system(size: 12))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                        }
                        
                        // Tags
                        if !tea.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(tea.tags.prefix(3), id: \.id) { tag in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color(hex: tag.color))
                                                .frame(width: 8, height: 8)
                                            Text(tag.name)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color.teaTextSecondaryAlt)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.teaBackgroundAlt.opacity(0.5))
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Arrow
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.teaTextSecondaryAlt.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .buttonStyle(ScaledButtonStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 48))
                .foregroundColor(Color.teaTextSecondaryAlt.opacity(0.5))
            
            Text("No teas in your collection yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.teaTextSecondaryAlt)
            
            Text("Add some teas to get daily recommendations")
                .font(.system(size: 14))
                .foregroundColor(Color.teaTextSecondaryAlt.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }
    
    private func loadTeaOfTheDay() {
        isLoading = true
        
        // Fetch tea of the day from backend
        Task {
            await manager.fetchTeaOfTheDay()
            
            DispatchQueue.main.async {
                if let backendTea = self.manager.teaOfTheDay {
                    // Convert backend tea to TeaInfo format
                    self.todaysTea = self.convertToTeaInfo(backendTea.tea)
                    self.lastTeaDate = self.currentDateString
                    self.lastTeaID = backendTea.tea.id
                    self.isFromBackend = true
                } else {
                    // Fallback to random selection if backend doesn't provide tea of the day
                    self.isFromBackend = false
                    self.selectRandomTea()
                }
                self.isLoading = false
            }
        }
    }
    
    private func refreshTeaOfTheDay() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isLoading = true
            Task {
                // Force refresh from backend
                await manager.fetchTeaOfTheDay()
                
                DispatchQueue.main.async {
                    if let backendTea = self.manager.teaOfTheDay {
                        self.todaysTea = self.convertToTeaInfo(backendTea.tea)
                        self.lastTeaDate = self.currentDateString
                        self.lastTeaID = backendTea.tea.id
                        self.isFromBackend = true
                    } else {
                        self.isFromBackend = false
                        self.selectRandomTea()
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    private func selectRandomTea() {
        // Collect all teas from all collections
        var allTeas: [TeaInfo] = []
        
        for collection in manager.collections {
            for record in collection.records {
                // Create TeaInfo from record data
                let tea = TeaInfo(
                    meta: TeaMeta(
                        id: record.id,
                        expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60), // Default 1 year
                        brewingTemp: 85 // Default temp
                    ),
                    data: TeaData(
                        name: record.data.name,
                        type: GraphQLEnum(record.data.type),
                        description: record.data.description
                    ),
                    tags: [] // Tags not available in record
                )
                allTeas.append(tea)
            }
        }
        
        if !allTeas.isEmpty {
            // Select a random tea, avoiding the previous one if possible
            var selectedTea = allTeas.randomElement()
            
            // If we have more than one tea and selected the same as yesterday, try again
            if allTeas.count > 1 && selectedTea?.meta.id == lastTeaID {
                selectedTea = allTeas.randomElement()
            }
            
            todaysTea = selectedTea
            
            // Save the selection
            if let tea = selectedTea {
                lastTeaDate = currentDateString
                lastTeaID = tea.meta.id
            }
        }
        
        isLoading = false
    }
    
    private func convertToTeaInfo(_ record: TeaOfTheDayQuery.Data.TeaOfTheDay.Tea) -> TeaInfo {
        // record is a QRRecord: includes meta and nested tea
        let tea = record.tea
        let tags = tea.tags.map { tag in
            Tag(
                id: tag.id,
                name: tag.name,
                color: tag.color,
                category: tag.category.name
            )
        }
        return TeaInfo(
            meta: TeaMeta(
                id: tea.id,
                expirationDate: ISO8601DateFormatter().date(from: record.expirationDate) ?? Date().addingTimeInterval(365 * 24 * 60 * 60),
                brewingTemp: record.bowlingTemp
            ),
            data: TeaData(
                name: tea.name,
                type: tea.type,
                description: tea.description
            ),
            tags: tags
        )
    }
    
    private func findTeaByID(_ id: String) -> TeaInfo? {
        for collection in manager.collections {
            for record in collection.records {
                if record.id == id {
                    return TeaInfo(
                        meta: TeaMeta(
                            id: record.id,
                            expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
                            brewingTemp: 85
                        ),
                        data: TeaData(
                            name: record.data.name,
                            type: GraphQLEnum(record.data.type),
                            description: record.data.description
                        ),
                        tags: []
                    )
                }
            }
        }
        return nil
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
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
            return "Tea"
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

// ScaledButtonStyle is already defined in CollectionsUIView.swift
// Using the shared version from there

struct TeaOfTheDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        TeaOfTheDayWidget(manager: CollectionsManager())
            .frame(height: 200)
            .padding()
    }
}
