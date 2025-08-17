//
//  EnhancedNewCard.swift
//  TeaElephant
//
//  Beautiful form for adding new tea with tea-inspired design
//

import SwiftUI
import Combine
import CodeScanner
import TeaElephantSchema

struct EnhancedNewCard: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var searcher = Searcher(Search())
    @State private var name = ""
    @State private var type = Type_Enum.tea
    @State private var description = ""
    @State private var expirationDate = Foundation.Date()
    @State private var brewingTemp: String = "100"
    @State private var readQRCode = false
    @State private var showSuccessAnimation = false
    
    var body: some View {
#if APPCLIP
        FullAppOffer()
#else
        if readQRCode {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
                switch result {
                case .success(let code):
                    Task {
                        await saveQR(code.string)
                        readQRCode = false
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    readQRCode = false
                }
            }
        } else {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.94, blue: 0.89),
                        Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                            .padding(.top, 20)
                        
                        // Form sections
                        VStack(spacing: 20) {
                            // Basic Info Section
                            formSection(title: "Basic Information", icon: "info.circle.fill") {
                                // Name field
                                formField(label: "Tea Name", icon: "leaf.fill") {
                                    TextField("Enter tea name", text: $name)
                                        .onChange(of: name) { _, newValue in
                                            search(newValue)
                                        }
                                }
                                
                                // Type picker
                                if searcher.detectedInfo == nil {
                                    formField(label: "Type", icon: "tag.fill") {
                                        Picker(selection: $type, label: EmptyView()) {
                                            Label("Tea", systemImage: "leaf.fill")
                                                .tag(Type_Enum.tea)
                                            Label("Coffee", systemImage: "cup.and.saucer.fill")
                                                .tag(Type_Enum.coffee)
                                            Label("Herbal", systemImage: "leaf.arrow.circlepath")
                                                .tag(Type_Enum.herb)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                }
                            }
                            
                            // Search Result Display
                            if let searchData = searcher.detectedInfo {
                                searchResultCard(data: searchData)
                            } else {
                                // Description Section
                                formSection(title: "Description", icon: "text.alignleft") {
                                    descriptionField
                                }
                            }
                            
                            // Brewing Details Section
                            formSection(title: "Brewing Details", icon: "thermometer") {
                                // Expiration date
                                formField(label: "Use Until", icon: "calendar") {
                                    DatePicker("", selection: $expirationDate, displayedComponents: [.date])
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                                
                                // Temperature
                                formField(label: "Temperature", icon: "thermometer") {
                                    HStack {
                                        TextField("100", text: $brewingTemp)
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.trailing)
                                        Text("°C")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save buttons
                        saveButtons
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }
                }
                .keyboardAdaptive()
                
                // Success animation overlay
                if showSuccessAnimation {
                    successOverlay
                }
            }
            .navigationBarTitle("Add New Tea", displayMode: .large)
        }
#endif
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.2),
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
            }
            
            Text("Create a new tea entry")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Form Section
    private func formSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            // Section content
            VStack(spacing: 12) {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
            )
        }
    }
    
    // MARK: - Form Field
    private func formField<Content: View>(
        label: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.55, green: 0.43, blue: 0.31))
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            content()
                .font(.system(size: 16))
        }
    }
    
    // MARK: - Description Field
    private var descriptionField: some View {
        TextEditor(text: $description)
            .frame(minHeight: 100)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.5))
            )
            .overlay(
                Group {
                    if description.isEmpty {
                        Text("Enter tea description...")
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                },
                alignment: .topLeading
            )
    }
    
    // MARK: - Search Result Card
    private func searchResultCard(data: TeaInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                Text("Found matching tea")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(data.data.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                if let typeValue = data.data.type.value {
                    Text(typeValue.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.15))
                        )
                }
                
                Text(data.data.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Save Buttons
    private var saveButtons: some View {
        VStack(spacing: 12) {
            // Primary NFC button
            Button(action: {
                Task {
                    await saveNFC()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 20))
                    Text("Save to NFC Tag")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.71, blue: 0.55),
                            Color(red: 0.45, green: 0.61, blue: 0.45)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(name.isEmpty)
            .opacity(name.isEmpty ? 0.6 : 1)
            
            // Secondary QR button
            Button(action: {
                withAnimation {
                    getQR()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 20))
                    Text("Save to QR Code")
                        .font(.system(size: 17, weight: .medium))
                }
                .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.55, green: 0.71, blue: 0.55), lineWidth: 2)
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(name.isEmpty)
            .opacity(name.isEmpty ? 0.6 : 1)
        }
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
                }
                
                Text("Tea Saved Successfully!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(showSuccessAnimation ? 1 : 0.5)
            .opacity(showSuccessAnimation ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showSuccessAnimation)
        }
    }
    
    // MARK: - Actions
    func saveNFC() async {
        if let searcherData = searcher.detectedInfo {
            do {
                try tagWriter().writeData(info: searcherData.meta)
                await showSuccess()
                resetState()
            } catch {
                print(error.localizedDescription)
            }
            return
        }
        
        guard let temp = Int(brewingTemp) else {
            print("Brewing temperature is not a valid number")
            return
        }
        
        let data = TeaData(
            name: name,
            type: GraphQLEnum(Type_Enum(rawValue: type.rawValue)!),
            description: description
        )
        
        do {
            let w = writer(extend: RecordWriter(), meta: tagWriter())
            try await w.write(data, expirationDate: expirationDate, brewingTemp: temp)
            await showSuccess()
            resetState()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func search(_ prefix: String) {
        Task {
            if !prefix.isEmpty {
                await searcher.search(prefix: prefix)
            }
        }
    }
    
    private func resetState() {
        name = ""
        type = Type_Enum.tea
        description = ""
        expirationDate = Date()
        brewingTemp = "100"
    }
    
    private func getQR() {
        readQRCode = true
    }
    
    private func saveQR(_ code: String) async {
        guard let temp = Int(brewingTemp) else {
            print("Brewing temperature is not a valid number")
            return
        }
        
        if let searcherData = searcher.detectedInfo {
            await QRManager().write(id: code, data: TeaMeta(id: searcherData.meta.id, expirationDate: expirationDate, brewingTemp: temp))
            await showSuccess()
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
            await showSuccess()
            resetState()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    private func showSuccess() async {
        withAnimation(.spring()) {
            showSuccessAnimation = true
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        withAnimation(.spring()) {
            showSuccessAnimation = false
        }
    }
}

struct EnhancedNewCard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnhancedNewCard()
        }
    }
}