//
//  RecomendationUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 01/09/2023.
//

import SwiftUI
import TeaElephantSchema
import HealthKit
import os

struct RecomendationUIView: View {
    var id: String
    @ObservedObject var manager: CollectionsManager
    @State private var feelings = ""
    @State private var type = Type_Enum.unknown
    @State private var withAdditives = true
    @State private var isTyping = false
    @FocusState private var isFocused: Bool
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var retryCount = 0
    private let maxRetries = 3
    private let wellnessLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Wellness")
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.teaBackgroundAlt,
                    Color.teaPrimaryAlt.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundColor(Color.vibrantBlue)
                            Text("AI Tea Recommendations")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color.teaTextPrimaryAlt)
                        }
                        
                        Text("Tell me how you're feeling and I'll find the perfect tea for you")
                            .font(.system(size: 14))
                            .foregroundColor(Color.teaTextSecondaryAlt)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Filter Options Card
                    VStack(spacing: 20) {
                        // Type Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Tea Type", systemImage: "leaf.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach([
                                        (Type_Enum.unknown, "Any", "sparkles"),
                                        (Type_Enum.tea, "Tea", "leaf.fill"),
                                        (Type_Enum.coffee, "Coffee", "cup.and.saucer.fill"),
                                        (Type_Enum.herb, "Herb", "leaf.arrow.circlepath")
                                    ], id: \.0) { value, label, icon in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                type = value
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: icon)
                                                    .font(.system(size: 14))
                                                Text(label)
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .foregroundColor(type == value ? .white : Color.teaTextPrimaryAlt)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background {
                                                if type == value {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.teaPrimaryAlt)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(.ultraThinMaterial)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(Color.glassBorder, lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }
                                        .buttonStyle(ScaledButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        // Additives Toggle
                        HStack {
                            Label("Include Additives", systemImage: "plus.circle")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                            
                            Spacer()
                            
                            Toggle("", isOn: $withAdditives)
                                .tint(Color.teaPrimaryAlt)
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Feelings Input Card
                    VStack(spacing: 16) {
                        Label("How are you feeling?", systemImage: "heart.text.square")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.teaTextSecondaryAlt)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            // Multiline editor that expands when text is present
                            TextEditor(text: $feelings)
                                .frame(minHeight: feelings.isEmpty ? 44 : 96, alignment: .topLeading)
                                .scrollIndicators(.hidden)
                                .scrollContentBackground(.hidden)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.glassBorder, lineWidth: 1)
                                        )
                                )
                                .focused($isFocused)
                                .onTapGesture { isTyping = true }
                                .onChange(of: feelings) { _, _ in isTyping = !feelings.isEmpty }

                            // Fancy Auto-Fill button (Wellness V1)
                            Button(action: {
                                isFocused = false
                                Task { await autoFillFeelings() }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.vibrantBlue, Color.teaPrimaryAlt],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .shadow(color: Color.vibrantBlue.opacity(0.35), radius: 8, x: 0, y: 3)
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                .accessibilityLabel("Auto-Fill Feelings")
                            }
                            .buttonStyle(ScaledButtonStyle())

                            // Submit button
                            Button(action: {
                                isFocused = false
                                Task {
                                    await requestRecommendation()
                                }
                            }) {
                                Image(systemName: "sparkles.rectangle.stack.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.vibrantBlue,
                                                        Color.teaPrimaryAlt
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                            }
                            .buttonStyle(ScaledButtonStyle())
                            .disabled(feelings.isEmpty || manager.recomendationLoading)
                            .opacity(feelings.isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Error Banner
                    if manager.error != nil {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.vibrantOrange)
                            
                            Text("Failed to load recommendation")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.teaTextPrimaryAlt)
                            
                            Spacer()
                            
                            Button("Retry") {
                                Task {
                                    await retryLastRequest()
                                }
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.vibrantBlue)
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.vibrantOrange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.vibrantOrange.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Results Section
                    if manager.recomendationLoading {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .stroke(Color.glassBorder, lineWidth: 3)
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: 0.6)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.vibrantBlue, Color.teaPrimaryAlt],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                    .animation(
                                        .linear(duration: 1)
                                        .repeatForever(autoreverses: false),
                                        value: manager.recomendationLoading
                                    )
                            }
                            
                            Text("AI is crafting your perfect recommendation...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    } else if let text = manager.lastRecomendation {
                        VStack(spacing: 20) {
                            // Recommendation Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.vibrantBlue)
                                    Text("Your Recommendation")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.teaTextPrimaryAlt)
                                }
                                
                                Text(LocalizedStringKey(text))
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.teaTextPrimaryAlt)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
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
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.teaPrimaryAlt.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 20)
                            
                            // Try Another Button
                            Button(action: {
                                Task {
                                    await requestAnotherRecommendation()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Try Another")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(Color.teaPrimaryAlt)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.teaPrimaryAlt.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                            .buttonStyle(ScaledButtonStyle())
                            .disabled(manager.recomendationLoading)
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Recommendation Error", isPresented: $showErrorAlert) {
            Button("Retry") {
                Task {
                    await retryLastRequest()
                }
            }
            Button("Cancel", role: .cancel) {
                resetErrorState()
            }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Error Handling Methods
    
    private func requestRecommendation() async {
        do {
            // Reset error state
            resetErrorState()
            
            // Validate input
            guard !feelings.isEmpty else {
                showError("Please describe how you're feeling")
                return
            }
            
            // Make the request
            manager.recomendation(id, feelings: feelings)
            
            // Check for errors after a delay (since manager doesn't use async)
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            
            if manager.error != nil {
                handleManagerError()
            }
        } catch {
            showError("Failed to get recommendation: \(error.localizedDescription)")
        }
    }
    
    private func requestAnotherRecommendation() async {
        do {
            resetErrorState()
            
            // Validate we have a previous recommendation
            guard manager.lastRecomendation != nil else {
                showError("No previous recommendation to refresh")
                return
            }
            
            manager.anotherRecomendation(id)
            
            // Check for errors after a delay
            try await Task.sleep(nanoseconds: 100_000_000)
            
            if manager.error != nil {
                handleManagerError()
            }
        } catch {
            showError("Failed to get another recommendation: \(error.localizedDescription)")
        }
    }
    
    private func handleManagerError() {
        if let error = manager.error {
            let errorText = error.localizedDescription
            
            // Check for specific error types
            if errorText.contains("network") || errorText.contains("connection") {
                showError("Network connection error. Please check your internet and try again.")
            } else if errorText.contains("auth") || errorText.contains("user not found") {
                showError("Authentication error. Please sign in again.")
            } else if errorText.contains("timeout") {
                showError("Request timed out. Please try again.")
            } else {
                showError("An error occurred: \(errorText)")
            }
        }
    }
    
    private func retryLastRequest() async {
        retryCount += 1
        
        if retryCount >= maxRetries {
            showError("Maximum retry attempts reached. Please try again later.")
            retryCount = 0
            return
        }
        
        // Retry the last action
        if !feelings.isEmpty {
            await requestRecommendation()
        } else if manager.lastRecomendation != nil {
            await requestAnotherRecommendation()
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    private func resetErrorState() {
        errorMessage = ""
        showErrorAlert = false
        retryCount = 0
    }

    // MARK: - Wellness Auto-Fill (V1)
    private func autoFillFeelings() async {
        do {
            let ok = try await HealthKitManager.shared.requestAuthorization()
            guard ok else { return }
            async let sleepH = HealthKitManager.shared.fetchSleepHoursLastNight()
            async let sleepAvg = HealthKitManager.shared.averageSleepHours(last: 7)
            async let intense = HealthKitManager.shared.hasIntenseWorkoutToday()
            async let workoutSummary = HealthKitManager.shared.workoutSummaryToday()
            async let rhr = HealthKitManager.shared.mostRecentQuantity(.restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()))
            async let rhrAvg = HealthKitManager.shared.averageQuantity(.restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()), last: 7)
            async let hrv = HealthKitManager.shared.mostRecentQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
            async let hrvAvg = HealthKitManager.shared.averageQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli), last: 7)
            async let stepsDict = HealthKitManager.shared.stepsByDay(last: 7)
            async let mindful = HealthKitManager.shared.hasMindfulnessToday()
            async let vo2 = HealthKitManager.shared.mostRecentVO2Max()
            async let vo2Avg = HealthKitManager.shared.averageVO2Max7d()
            async let waterToday = HealthKitManager.shared.waterTodayLiters()
            async let waterAvg = HealthKitManager.shared.averageDailyWaterLiters(last: 7)

            let steps = await stepsDict
            let todayKey = Calendar.current.startOfDay(for: Date())
            let ws = await workoutSummary
            let signals = WellnessSignals(
                sleepHoursLastNight: await sleepH,
                avgSleepHours7d: await sleepAvg,
                intenseWorkoutToday: await intense,
                workoutCountToday: ws.count,
                longestWorkoutMinutes: ws.longestMinutes,
                totalActiveEnergyKcal: ws.totalEnergyKcal,
                restingHR: await rhr,
                hrvSDNN: await hrv,
                avgRestingHR7d: await rhrAvg,
                avgHRV7d: await hrvAvg,
                stepsToday: steps[todayKey],
                avgSteps7d: steps.isEmpty ? nil : (steps.values.reduce(0,+) / Double(steps.count)),
                mindfulToday: await mindful,
                vo2Max: await vo2,
                avgVO2Max7d: await vo2Avg,
                waterTodayLiters: await waterToday,
                avgWaterLiters7d: await waterAvg
            )
            let text = WellnessTextGenerator.generate(from: signals)
            if !text.isEmpty {
                feelings = text
            }
        } catch {
            wellnessLogger.error("Wellness autofill failed: \(String(describing: error), privacy: .public)")
        }
    }
}

#Preview {
    NavigationView {
        RecomendationUIView(id: "", manager: CollectionsManager())
    }
}
