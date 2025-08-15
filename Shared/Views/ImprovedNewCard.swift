//
//  ImprovedNewCard.swift
//  TeaElephant
//
//  Improved form layout for adding new tea
//

import SwiftUI
import Combine
import CodeScanner
import UIKit
import TeaElephantSchema

@available(iOS 15.0, *)
struct ImprovedNewCard: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var searcher = Searcher(Search())
    
    // Form states
    @State private var name = ""
    @State private var type = Type_Enum.tea
    @State private var description = ""
    @State private var expirationDate = Date()
    @State private var brewingTemp = "95"
    @State private var brewingTime = "3"
    @State private var servingSize = "250"
    
    // UI states
    @State private var readQRCode = false
    @State private var currentSection = 0
    @State private var showingSaveOptions = false
    @State private var saveSuccess = false
    
    var body: some View {
        NavigationView {
            if readQRCode {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Tea Data") { result in
                    switch result {
                    case .success(let code):
                        Task{
                            await saveQR(code.string)
                            readQRCode = false
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        readQRCode = false
                    }
                }
            } else {
                Form {
                    // Section 1: Basic Information
                    Section {
                        VStack(alignment: .leading, spacing: TeaSpacing.small) {
                            Label("Basic Information", systemImage: "leaf.fill")
                                .font(TeaTypography.headline)
                                .foregroundColor(.teaPrimary)
                            
                            TextField("Tea Name", text: $name)
                                .onChange(of: name, perform: search)
                                .textFieldStyle(.roundedBorder)
                            
                            if let searchData = searcher.detectedInfo {
                                VStack(alignment: .leading, spacing: TeaSpacing.xSmall) {
                                    Text("Found: \(searchData.data.name)")
                                        .font(TeaTypography.caption)
                                        .foregroundColor(.teaSuccess)
                                    Text("Type: \(searchData.data.type.value?.rawValue ?? "Unknown")")
                                        .font(TeaTypography.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, TeaSpacing.xSmall)
                                .padding(.horizontal, TeaSpacing.small)
                                .background(Color.teaSuccess.opacity(0.1))
                                .cornerRadius(TeaCorners.small)
                            }
                            
                            Picker("Type", selection: $type) {
                                Label("Tea", systemImage: "leaf").tag(Type_Enum.tea)
                                Label("Coffee", systemImage: "cup.and.saucer").tag(Type_Enum.coffee)
                                Label("Herb", systemImage: "leaf.arrow.circlepath").tag(Type_Enum.herb)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.vertical, TeaSpacing.xSmall)
                    }
                    
                    // Section 2: Description
                    Section {
                        VStack(alignment: .leading, spacing: TeaSpacing.small) {
                            Label("Description & Notes", systemImage: "text.alignleft")
                                .font(TeaTypography.headline)
                                .foregroundColor(.teaPrimary)
                            
                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: TeaCorners.small)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.vertical, TeaSpacing.xSmall)
                    }
                    
                    // Section 3: Brewing Instructions
                    Section {
                        VStack(alignment: .leading, spacing: TeaSpacing.medium) {
                            Label("Brewing Instructions", systemImage: "thermometer")
                                .font(TeaTypography.headline)
                                .foregroundColor(.teaPrimary)
                            
                            HStack {
                                Image(systemName: "thermometer")
                                    .foregroundColor(.teaSecondary)
                                Text("Temperature")
                                Spacer()
                                TextField("95", text: $brewingTemp)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                Text("°C")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(.teaSecondary)
                                Text("Brewing Time")
                                Spacer()
                                TextField("3", text: $brewingTime)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                Text("min")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "drop")
                                    .foregroundColor(.teaSecondary)
                                Text("Water Amount")
                                Spacer()
                                TextField("250", text: $servingSize)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                Text("ml")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, TeaSpacing.xSmall)
                    }
                    
                    // Section 4: Storage
                    Section {
                        VStack(alignment: .leading, spacing: TeaSpacing.medium) {
                            Label("Storage Information", systemImage: "calendar")
                                .font(TeaTypography.headline)
                                .foregroundColor(.teaPrimary)
                            
                            DatePicker("Best Before", selection: $expirationDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                        .padding(.vertical, TeaSpacing.xSmall)
                    }
                    
                    // Section 5: Save Options
                    Section {
                        VStack(spacing: TeaSpacing.medium) {
                            Button(action: {
                                Task {
                                    await saveNFC()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "wave.3.right.circle.fill")
                                    Text("Save to NFC Tag")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(TeaPrimaryButtonStyle())
                            
                            Button(action: {
                                withAnimation {
                                    getQR()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "qrcode")
                                    Text("Generate QR Code")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(TeaSecondaryButtonStyle())
                        }
                        .padding(.vertical, TeaSpacing.small)
                    }
                }
                .navigationTitle("Add New Tea")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.teaSecondary)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                await saveNFC()
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.teaPrimary)
                        .disabled(name.isEmpty)
                    }
                }
                .alert("Success", isPresented: $saveSuccess) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text("Tea information has been saved successfully!")
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func search(_ searchname: String) {
        if !searchname.isEmpty && searchname.count > 2 {
            searcher.search(searchname)
        }
    }
    
    func saveNFC() async {
        // Implementation from original file
        if let searcherData = searcher.detectedInfo {
            do {
                let w = writer(extend: RecordWriter(), meta: tagWriter())
                try await w.write(searcherData.data)
                saveSuccess = true
            } catch {
                print(error.localizedDescription)
            }
            return
        }
        
        guard let tempValue = Int(brewingTemp) else {
            print("Brewing temperature is not a valid number")
            return
        }
        
        let data = TeaData(
            name: name,
            type: GraphQLEnum(type),
            description: description
        )
        
        do {
            let w = writer(extend: RecordWriter(), meta: tagWriter())
            try await w.write(data, expirationDate: expirationDate, brewingTemp: tempValue)
            saveSuccess = true
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getQR() {
        readQRCode = true
    }
    
    func saveQR(_ qrcode: String) async {
        // Implementation from original file
        if let searcherData = searcher.detectedInfo {
            do {
                let qr = QRwriter(with: qrcode)
                let w = writer(extend: RecordWriter(), meta: qr)
                try await w.write(searcherData.data)
                print("Saved successfully")
            } catch {
                print(error.localizedDescription)
            }
            return
        }
        
        guard let tempValue = Int(brewingTemp) else {
            print("Brewing temperature is not a valid number")
            return
        }
        
        let data = TeaData(
            name: name,
            type: GraphQLEnum(type),
            description: description
        )
        
        do {
            let qr = QRwriter(with: qrcode)
            let w = writer(extend: RecordWriter(), meta: qr)
            try await w.write(data, expirationDate: expirationDate, brewingTemp: tempValue)
            print("Saved successfully")
        } catch {
            print(error.localizedDescription)
        }
    }
}