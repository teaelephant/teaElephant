//
//  EnhancedCardViewer.swift
//  TeaElephant
//
//  Enhanced card viewer with beautiful tea-inspired design
//

import SwiftUI
import os
import CodeScanner

private let logQR = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "QR")

struct EnhancedCardViewer: View {
    @StateObject private var reader = Reader(infoReader: NFCReader(), extender: RecordGetter())
    @State private var readQRCode = false
    @State private var showingEnhancedCard = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.94, blue: 0.89),
                    Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.9),
                    Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if readQRCode {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
                    switch result {
                    case .success(let code):
                        Task {
                            await processQR(code.string)
                            readQRCode = false
                            showingEnhancedCard = true
                        }
                    case .failure(let error):
                        logQR.error("QR scan error: \(error.localizedDescription, privacy: .public)")
                        readQRCode = false
                    }
                }
            } else {
                VStack(spacing: 24) {
                    // Error display with better design
                    if let err = reader.error {
                        errorBanner(message: err)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Content area
                    if showingEnhancedCard || reader.detectedInfo != nil {
                        EnhancedShowCard(info: $reader.detectedInfo)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        emptyStateView
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    actionButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitle("Read Tea Info", displayMode: .large)
        .animation(.spring(), value: showingEnhancedCard)
    }
    
    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.85, green: 0.35, blue: 0.35))
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.85, green: 0.35, blue: 0.35))
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.85, green: 0.35, blue: 0.35).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.85, green: 0.35, blue: 0.35).opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 5_000_000_000)
                withAnimation {
                    reader.error = nil
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            // Illustration
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.1),
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sensor.tag.radiowaves.forward")
                    .font(.system(size: 56))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
            }
            
            VStack(spacing: 12) {
                Text("Ready to Scan")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Use NFC or QR code to read tea information")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Visual hint cards
            HStack(spacing: 16) {
                hintCard(icon: "wave.3.right", text: "NFC")
                hintCard(icon: "qrcode", text: "QR")
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func hintCard(icon: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary NFC button
            Button(action: {
                withAnimation(.spring()) {
                    readNFC()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 20))
                    Text("Read NFC Tag")
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
            
            // Secondary QR button
            Button(action: {
                withAnimation(.spring()) {
                    readQR()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 20))
                    Text("Scan QR Code")
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
        }
    }
    
    // MARK: - Actions
    private func processQR(_ code: String) async {
        await reader.processQRCode(code)
        logQR.info("QR processed successfully")
    }
    
    func readNFC() {
        reader.readInfo()
        showingEnhancedCard = true
        logQR.info("NFC read started")
    }
    
    func readQR() {
        readQRCode = true
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct EnhancedCardViewer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnhancedCardViewer()
        }
    }
}
