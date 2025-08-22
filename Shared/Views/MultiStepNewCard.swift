//
//  MultiStepNewCard.swift
//  TeaElephant
//
//  Multi-step form with validation for adding new tea
//

import SwiftUI
import Combine
import CodeScanner
import TeaElephantSchema
import UIKit

// MARK: - Haptic Feedback Helper
// Note: Using the shared HapticFeedback from Utilities

struct MultiStepNewCard: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var searcher = Searcher(Search())
    
    // Form state
    @State private var name = ""
    @State private var type = Type_Enum.tea
    @State private var description = ""
    @State private var expirationDate = Foundation.Date()
    @State private var brewingTemp: String = "85"
    @State private var brewingTime: String = "3"
    @State private var servingSize: String = "250"
    @State private var readQRCode = false
    
    // UI state
    @State private var currentStep = 1
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    @State private var stepTransitionOpacity = 1.0
    @State private var isStepAnimating = false
    @State private var isUsingExistingTea = false
    
    // Validation state
    @State private var nameError = ""
    @State private var tempError = ""
    @State private var descriptionError = ""
    
    private let totalSteps = 3
    
    var body: some View {
#if APPCLIP
        FullAppOffer()
#else
        Group {
            if readQRCode {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
                    switch result {
                    case .success(let code):
                        Task {
                            await saveQR(code.string)
                            readQRCode = false
                        }
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showingErrorAlert = true
                        readQRCode = false
                    }
                }
            } else {
                NavigationView {
                    ZStack {
                        // Liquid glass background
                        LiquidBackground(
                            primaryColor: Color.teaPrimaryAlt,
                            secondaryColor: Color.vibrantBlue
                        )
                        .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            // Custom Navigation Bar
                            customNavigationBar
                            
                            // Progress Bar
                            progressBar
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            
                            // Step Content
                            ScrollView {
                                VStack(spacing: 24) {
                                    // Step indicator
                                    stepIndicator
                                    
                                    // Form content based on current step
                                    Group {
                                        switch currentStep {
                                        case 1:
                                            basicInfoStep
                                        case 2:
                                            detailsStep
                                        case 3:
                                            reviewStep
                                        default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                                    
                                    // Navigation buttons
                                    navigationButtons
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 30)
                                }
                            }
                        }
                        
                        // Processing overlay
                        if isProcessing {
                            processingOverlay
                        }
                    }
                    .navigationBarHidden(true)
                }
            }
        }
        .alert("Success!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Tea information has been saved successfully!")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
#endif
    }
    
    // MARK: - Custom Navigation Bar with Glass Effect
    private var customNavigationBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Cancel")
                        .font(.system(size: 17))
                }
                .foregroundColor(Color.teaAccentAlt)
                .if(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil) { view in
                    view.glassTextStyle(color: Color.teaAccentAlt)
                }
            }
            
            Spacer()
            
            Text("Add New Tea")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
                .if(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil) { view in
                    view.glassTextStyle()
                }
            
            Spacer()
            
            // Balance spacing
            Color.clear
                .frame(width: 70, height: 30)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            Color.clear.background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 8)
                
                // Progress
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.71, blue: 0.55),
                                Color(red: 0.35, green: 0.51, blue: 0.35)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * (Double(currentStep) / Double(totalSteps)), height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
        }
        .frame(height: 8)
    }
    
    // MARK: - Step Indicator
    private var stepIndicator: some View {
        VStack(spacing: 8) {
            Text("Step \(currentStep) of \(totalSteps)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(stepTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.35, green: 0.51, blue: 0.35))
            
            Text(stepDescription)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 1: return "Basic Information"
        case 2: return "Tea Details"
        case 3: return "Review & Save"
        default: return ""
        }
    }
    
    private var stepDescription: String {
        switch currentStep {
        case 1: return "Enter the name and type of your tea"
        case 2: return "Add brewing details and description"
        case 3: return "Review and choose storage method"
        default: return ""
        }
    }
    
    // MARK: - Step 1: Basic Info
    private var basicInfoStep: some View {
        VStack(spacing: 20) {
            // Name field
            VStack(alignment: .leading, spacing: 12) {
                Label("Tea Name *", systemImage: "leaf.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    if isUsingExistingTea {
                        // Just show the name as text when using existing tea
                        Text(name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        // Show editable field when creating new tea
                        TextField("e.g., Dragon Well Green Tea", text: $name)
                            .textFieldStyle(EnhancedTextFieldStyle(isValid: nameError.isEmpty))
                            .onChange(of: name) { _, newValue in
                                validateName()
                                search(newValue)
                            }
                    }
                    
                    if !nameError.isEmpty && !isUsingExistingTea {
                        Label(nameError, systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: nameError)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.glassBorder,
                                        Color.teaPrimaryAlt.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.glassShadow, radius: 8, x: 0, y: 3)
            }
            
            // Search results
            if let searchData = searcher.detectedInfo {
                searchResultCard(searchData)
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Type selection
            VStack(alignment: .leading, spacing: 12) {
                Label("Type *", systemImage: "tag.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                if isUsingExistingTea {
                    // Just show the type as text when using existing tea
                    Text(type.rawValue.capitalized)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                } else {
                    // Show selectable buttons when creating new tea
                    VStack(spacing: 12) {
                        ForEach([Type_Enum.tea, Type_Enum.coffee, Type_Enum.herb], id: \.self) { teaType in
                            typeSelectionButton(teaType)
                        }
                    }
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.glassBorder,
                                        Color.teaPrimaryAlt.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.glassShadow, radius: 8, x: 0, y: 3)
            }
        }
    }
    
    // MARK: - Step 2: Details
    private var detailsStep: some View {
        VStack(spacing: 20) {
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Label("Description", systemImage: "text.alignleft")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    if isUsingExistingTea {
                        // Just show the description as text when using existing tea
                        if !description.isEmpty {
                            Text(description)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("No description available")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    } else {
                        // Show editable text field when creating new tea
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .frame(minHeight: 120)
                                .padding(4)
                                .background(Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.3))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(descriptionError.isEmpty ? Color.secondary.opacity(0.2) : Color.red.opacity(0.5), lineWidth: 1)
                                )
                                .onChange(of: description) { _, _ in
                                    validateDescription()
                                }
                            
                            if description.isEmpty {
                                Text("Describe the tea's flavor, origin, or special characteristics...")
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    if !isUsingExistingTea {
                        HStack {
                            if !descriptionError.isEmpty {
                                Label(descriptionError, systemImage: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            Text("\(description.count)/500")
                                .font(.system(size: 12))
                                .foregroundColor(description.count > 500 ? .red : .secondary)
                        }
                    }
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.glassBorder,
                                        Color.teaPrimaryAlt.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.glassShadow, radius: 8, x: 0, y: 3)
            }
            
            // Brewing details
            VStack(spacing: 16) {
                // Temperature
                VStack(alignment: .leading, spacing: 12) {
                    Label("Brewing Temperature", systemImage: "thermometer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        // Temperature slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(brewingTemp)°C")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.35, green: 0.51, blue: 0.35))
                                
                                Spacer()
                                
                                Text(temperatureDescription)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(temperatureColor.opacity(0.15))
                                    )
                            }
                            
                            Slider(value: Binding(
                                get: { Double(brewingTemp) ?? 85 },
                                set: { brewingTemp = String(Int($0)) }
                            ), in: 50...100, step: 5)
                            .accentColor(temperatureColor)
                            
                            // Quick presets
                            HStack(spacing: 8) {
                                ForEach([("Green", "70"), ("Oolong", "85"), ("Black", "95"), ("Herbal", "100")], id: \.0) { label, temp in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            brewingTemp = temp
                                        }
                                    }) {
                                        Text(label)
                                            .font(.system(size: 12, weight: brewingTemp == temp ? .semibold : .regular))
                                            .foregroundColor(brewingTemp == temp ? .white : .secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(brewingTemp == temp ? temperatureColor : Color.secondary.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        let tempErr = computedTempError()
                        if !tempErr.isEmpty {
                            Label(tempErr, systemImage: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Divider()
                
                // Expiration date
                VStack(alignment: .leading, spacing: 12) {
                    Label("Best Before Date", systemImage: "calendar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $expirationDate, in: Date()..., displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.glassBorder,
                                        Color.teaPrimaryAlt.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.glassShadow, radius: 8, x: 0, y: 3)
            }
        }
    }
    
    // MARK: - Step 3: Review
    private var reviewStep: some View {
        VStack(spacing: 20) {
            // Summary card
            VStack(alignment: .leading, spacing: 16) {
                Label("Review Your Tea", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                
                VStack(spacing: 12) {
                    summaryRow(icon: "leaf.fill", label: "Name", value: name.isEmpty ? "Not specified" : name)
                    summaryRow(icon: "tag.fill", label: "Type", value: type.rawValue)
                    if !description.isEmpty {
                        summaryRow(icon: "text.alignleft", label: "Description", value: String(description.prefix(50)) + (description.count > 50 ? "..." : ""))
                    }
                    summaryRow(icon: "thermometer", label: "Temperature", value: "\(brewingTemp)°C")
                    summaryRow(icon: "calendar", label: "Best Before", value: expirationDate.formatted(date: .abbreviated, time: .omitted))
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.glassBorder,
                                        Color.teaPrimaryAlt.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.glassShadow, radius: 8, x: 0, y: 3)
            }
            
            // Storage options
            VStack(spacing: 12) {
                Label("Choose Storage Method", systemImage: "archivebox.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                storageButton(
                    title: "Save to NFC Tag",
                    subtitle: "Write directly to physical tag",
                    icon: "wave.3.right",
                    color: Color(red: 0.55, green: 0.71, blue: 0.55),
                    isPrimary: true,
                    action: {
                        Task {
                            await saveNFC()
                        }
                    }
                )
                
                storageButton(
                    title: "Save to QR Code",
                    subtitle: "Generate printable QR code",
                    icon: "qrcode",
                    color: Color(red: 0.55, green: 0.43, blue: 0.31),
                    isPrimary: false,
                    action: {
                        withAnimation {
                            getQR()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Views
    private func typeSelectionButton(_ teaType: Type_Enum) -> some View {
        Button(action: {
            if !isUsingExistingTea {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    type = teaType
                }
            }
        }) {
            HStack {
                Image(systemName: iconForType(teaType))
                    .font(.system(size: 20))
                    .foregroundColor(type == teaType ? .white : Color(red: 0.55, green: 0.71, blue: 0.55))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(teaType.rawValue)
                        .font(.system(size: 16, weight: type == teaType ? .semibold : .regular))
                        .foregroundColor(type == teaType ? .white : .primary)
                    
                    Text(descriptionForType(teaType))
                        .font(.system(size: 12))
                        .foregroundColor(type == teaType ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if type == teaType {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(type == teaType ? 
                          LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.71, blue: 0.55),
                                Color(red: 0.35, green: 0.51, blue: 0.35)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                          ) : 
                          LinearGradient(
                            colors: [Color.secondary.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(type == teaType ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func iconForType(_ type: Type_Enum) -> String {
        switch type {
        case .tea: return "leaf.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .herb: return "leaf.arrow.circlepath"
        default: return "questionmark.circle"
        }
    }
    
    private func descriptionForType(_ type: Type_Enum) -> String {
        switch type {
        case .tea: return "Traditional tea leaves"
        case .coffee: return "Coffee beans and grounds"
        case .herb: return "Herbal and botanical infusions"
        default: return "Other beverages"
        }
    }
    
    private var temperatureColor: Color {
        guard let temp = Double(brewingTemp) else { return .gray }
        if temp < 70 { return .green }
        if temp < 85 { return .orange }
        return .red
    }
    
    private var temperatureDescription: String {
        guard let temp = Double(brewingTemp) else { return "Invalid" }
        if temp < 70 { return "Delicate" }
        if temp < 85 { return "Medium" }
        if temp < 95 { return "Full-bodied" }
        return "Boiling"
    }
    
    private func searchResultCard(_ data: TeaInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                Text("Found in database")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        // Clear the search result
                        searcher.detectedInfo = nil
                        // Reset form to allow manual entry
                        name = ""
                        type = .tea
                        description = ""
                        isUsingExistingTea = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    
                    Button(action: {
                        // Fill the form with the found tea's data
                        name = data.data.name
                        if let typeValue = data.data.type.value {
                            type = typeValue
                        }
                        description = data.data.description
                        // Mark that we're using an existing tea
                        isUsingExistingTea = true
                        // Note: Expiration date and brewing temperature remain editable by the user
                    }) {
                        Text("Use This")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.55, green: 0.71, blue: 0.55))
                            .cornerRadius(8)
                    }
                }
            }
            
            Text(data.data.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            if !data.data.description.isEmpty {
                Text(data.data.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Info message
            HStack(spacing: 4) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color.vibrantBlue)
                Text("You can still customize expiration date and temperature")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.05),
                    Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.3), lineWidth: 1)
        )
    }
    
    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func storageButton(title: String, subtitle: String, icon: String, color: Color, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isPrimary ? .white : color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isPrimary ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(isPrimary ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(isPrimary ? .white.opacity(0.8) : .secondary.opacity(0.5))
            }
            .padding(16)
            .background(
                isPrimary ?
                AnyView(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                ) :
                AnyView(Color.secondary.opacity(0.05))
            )
            .cornerRadius(16)
            .shadow(color: isPrimary ? color.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .disabled(!isFormValid())
        .opacity(isFormValid() ? 1 : 0.6)
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button(action: {
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        stepTransitionOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        currentStep -= 1
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            stepTransitionOpacity = 1
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.35, green: 0.51, blue: 0.35))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                }
            }
            
            if currentStep < totalSteps {
                Button(action: {
                    if validateCurrentStep() {
                        HapticFeedback.success()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            stepTransitionOpacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            currentStep += 1
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                stepTransitionOpacity = 1
                            }
                        }
                    } else {
                        HapticFeedback.error()
                    }
                }) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.71, blue: 0.55),
                                Color(red: 0.35, green: 0.51, blue: 0.35)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.3), radius: 4, y: 2)
                }
                .disabled(!canProceed)
                .opacity(canProceed ? 1 : 0.6)
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 1: return isUsingExistingTea || (!name.isEmpty && nameError.isEmpty)
        case 2: return tempError.isEmpty && (isUsingExistingTea || descriptionError.isEmpty)
        default: return true
        }
    }
    
    // MARK: - Processing Overlay
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Saving tea information...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color(red: 0.35, green: 0.51, blue: 0.35))
            .cornerRadius(20)
        }
    }
    
    // MARK: - Comprehensive Validation with Real-time Feedback
    private func validateName() {
        // Skip validation if using existing tea
        if isUsingExistingTea {
            nameError = ""
            return
        }
        
        // Trim whitespace for validation
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            nameError = ""
        } else if trimmedName.count < 2 {
            nameError = "Name must be at least 2 characters"
        } else if trimmedName.count > 100 {
            nameError = "Name is too long (max 100 characters)"
        } else if trimmedName.rangeOfCharacter(from: .alphanumerics) == nil {
            nameError = "Name must contain at least one letter or number"
        } else if trimmedName.contains(where: { $0.isNewline }) {
            nameError = "Name cannot contain line breaks"
        } else {
            nameError = ""
        }
    }
    
    private func validateTemperature() {
        guard !brewingTemp.isEmpty else {
            tempError = "Temperature is required"
            return
        }
        
        // Remove any non-numeric characters
        let cleanedTemp = brewingTemp.filter { $0.isNumber }
        
        guard let temp = Int(cleanedTemp) else {
            tempError = "Please enter a valid number"
            return
        }
        
        if temp < 50 {
            tempError = "Temperature too low (minimum 50°C)"
        } else if temp > 100 {
            tempError = "Temperature too high (maximum 100°C)"
        } else {
            tempError = ""
            // Auto-correct the input
            if brewingTemp != cleanedTemp {
                brewingTemp = cleanedTemp
            }
        }
    }
    
    private func validateDescription() {
        // Skip validation if using existing tea
        if isUsingExistingTea {
            descriptionError = ""
            return
        }
        
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedDescription.count > 500 {
            descriptionError = "Description is too long (max 500 characters)"
        } else if trimmedDescription.count > 0 && trimmedDescription.count < 10 {
            descriptionError = "Description should be at least 10 characters"
        } else if trimmedDescription.contains(where: { 
            // Check for potentially harmful characters
            "<>&\"'".contains($0)
        }) {
            descriptionError = "Description contains invalid characters"
        } else {
            descriptionError = ""
        }
    }

    // MARK: - Pure Validators (no state mutation)
    private func computedNameError() -> String {
        if isUsingExistingTea { return "" }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty { return "" }
        if trimmedName.count < 2 { return "Name must be at least 2 characters" }
        if trimmedName.count > 100 { return "Name is too long (max 100 characters)" }
        if trimmedName.rangeOfCharacter(from: .alphanumerics) == nil { return "Name must contain at least one letter or number" }
        if trimmedName.contains(where: { $0.isNewline }) { return "Name cannot contain line breaks" }
        return ""
    }

    private func computedTempError() -> String {
        guard !brewingTemp.isEmpty else { return "Temperature is required" }
        let cleanedTemp = brewingTemp.filter { $0.isNumber }
        guard let temp = Int(cleanedTemp) else { return "Please enter a valid number" }
        if temp < 50 { return "Temperature too low (minimum 50°C)" }
        if temp > 100 { return "Temperature too high (maximum 100°C)" }
        return ""
    }

    private func computedDescriptionError() -> String {
        if isUsingExistingTea { return "" }
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDescription.count > 500 { return "Description is too long (max 500 characters)" }
        if trimmedDescription.count > 0 && trimmedDescription.count < 10 { return "Description should be at least 10 characters" }
        if trimmedDescription.contains(where: { "<>&\"'".contains($0) }) { return "Description contains invalid characters" }
        return ""
    }
    
    // MARK: - Additional Validation Helpers
    private func validateBrewingTime() -> Bool {
        guard let time = Int(brewingTime) else { return false }
        return time > 0 && time <= 60 // Max 60 minutes
    }
    
    private func validateServingSize() -> Bool {
        guard let size = Int(servingSize) else { return false }
        return size >= 50 && size <= 1000 // Between 50ml and 1L
    }
    
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case 1:
            let err = computedNameError()
            return isUsingExistingTea || (err.isEmpty && !name.isEmpty)
        case 2:
            let tErr = computedTempError()
            let dErr = computedDescriptionError()
            return tErr.isEmpty && (isUsingExistingTea || dErr.isEmpty)
        default:
            return true
        }
    }
    
    private func isFormValid() -> Bool {
        let nErr = computedNameError()
        let tErr = computedTempError()
        let dErr = computedDescriptionError()
        return !name.isEmpty && (isUsingExistingTea || nErr.isEmpty) && tErr.isEmpty && (isUsingExistingTea || dErr.isEmpty)
    }
    
    // MARK: - Actions
    @MainActor
    func saveNFC() async {
        isProcessing = true
        defer { isProcessing = false }
        
        guard let temp = Int(brewingTemp) else {
            errorMessage = "Invalid temperature"
            showingErrorAlert = true
            return
        }
        
        // If an existing tea was found, use its ID but allow user to customize metadata
        if let searcherData = searcher.detectedInfo {
            do {
                // Create updated metadata with user's custom values
                let updatedMeta = TeaMeta(
                    id: searcherData.meta.id,
                    expirationDate: expirationDate,
                    brewingTemp: temp
                )
                try tagWriter().writeData(info: updatedMeta)
                showingSuccessAlert = true
                resetState()
            } catch {
                errorMessage = error.localizedDescription
                showingErrorAlert = true
            }
            return
        }
        
        // Create new tea if no existing tea was found
        let data = TeaData(
            name: name,
            type: GraphQLEnum(Type_Enum(rawValue: type.rawValue)!),
            description: description
        )
        
        do {
            let w = writer(extend: RecordWriter(), meta: tagWriter())
            try await w.write(data, expirationDate: expirationDate, brewingTemp: temp)
            showingSuccessAlert = true
            resetState()
        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
    
    private func search(_ prefix: String) {
        Task {
            if !prefix.isEmpty {
                await searcher.search(prefix: prefix)
            }
        }
    }
    
    @MainActor
    private func resetState() {
        name = ""
        type = Type_Enum.tea
        description = ""
        expirationDate = Date()
        brewingTemp = "85"
        currentStep = 1
        isUsingExistingTea = false
    }
    
    @MainActor
    private func getQR() {
        readQRCode = true
    }
    
    @MainActor
    private func saveQR(_ code: String) async {
        isProcessing = true
        defer { isProcessing = false }
        
        guard let temp = Int(brewingTemp) else {
            errorMessage = "Invalid temperature"
            showingErrorAlert = true
            return
        }
        
        if let searcherData = searcher.detectedInfo {
            await QRManager().write(id: code, data: TeaMeta(id: searcherData.meta.id, expirationDate: expirationDate, brewingTemp: temp))
            showingSuccessAlert = true
            resetState()
            return
        }
        
        let data = TeaData(
            name: name,
            type: GraphQLEnum(Type_Enum(rawValue: type.rawValue)!),
            description: description
        )
        
        do {
            let id = try await RecordWriter().writeExtendInfo(info: data)
            let meta = TeaMeta(id: id, expirationDate: expirationDate, brewingTemp: temp)
            await QRManager().write(id: code, data: meta)
            showingSuccessAlert = true
            resetState()
        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
}

// MARK: - Custom Styles
struct EnhancedTextFieldStyle: TextFieldStyle {
    let isValid: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isValid ? Color.secondary.opacity(0.2) : Color.red.opacity(0.5), lineWidth: 1)
            )
    }
}

struct MultiStepScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct MultiStepNewCard_Previews: PreviewProvider {
    static var previews: some View {
        MultiStepNewCard()
    }
}
