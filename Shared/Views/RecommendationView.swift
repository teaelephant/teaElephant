import SwiftUI
import HealthKit
import os

struct RecommendationView: View {
    @State private var feelings: String = ""
    @State private var isRequesting = false
    @State private var authGranted = false
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Wellness")

    var body: some View {
        Form {
            Section(header: Text("Describe how you feel")) {
                TextField("Optional feelings…", text: $feelings, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            Section {
                Button {
                    Task { await autoFill() }
                } label: {
                    if isRequesting {
                        ProgressView()
                    } else {
                        Label("Auto-Fill Feelings", systemImage: "wand.and.stars")
                    }
                }
                .disabled(isRequesting)
            } footer: {
                Text("Uses Health data (sleep, workouts, steps, HR/HRV, mindfulness) with your permission. Data stays on-device.")
            }
        }
        .navigationTitle("Wellness Helper")
    }

    @MainActor
    private func autoFill() async {
        isRequesting = true
        defer { isRequesting = false }
        do {
            let ok = try await HealthKitManager.shared.requestAuthorization()
            guard ok else { return }
            authGranted = true

            async let sleepH = HealthKitManager.shared.fetchSleepHoursLastNight()
            async let intense = HealthKitManager.shared.hasIntenseWorkoutToday()
            async let rhr = HealthKitManager.shared.mostRecentQuantity(.restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()))
            async let hrv = HealthKitManager.shared.mostRecentQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
            async let stepsDict = HealthKitManager.shared.stepsByDay(last: 7)
            async let mindful = HealthKitManager.shared.hasMindfulnessToday()

            let signals = await buildSignals(sleepH: sleepH, intense: intense, rhr: rhr, hrv: hrv, steps: stepsDict, mindful: mindful)
            let text = WellnessTextGenerator.generate(from: signals)
            if !text.isEmpty {
                feelings = text
            }
        } catch {
            logger.error("HealthKit auth or fetch failed: \(String(describing: error), privacy: .public)")
        }
    }

    private func buildSignals(sleepH: Double?, intense: Bool?, rhr: Double?, hrv: Double?, steps: [Date: Double], mindful: Bool?) -> WellnessSignals {
        let todayKey = Calendar.current.startOfDay(for: Date())
        let stepsToday = steps[todayKey]
        let avg = steps.isEmpty ? nil : (steps.values.reduce(0,+) / Double(steps.count))
        return WellnessSignals(sleepHoursLastNight: sleepH,
                               intenseWorkoutToday: intense,
                               restingHR: rhr,
                               hrvSDNN: hrv,
                               stepsToday: stepsToday,
                               avgSteps7d: avg,
                               mindfulToday: mindful)
    }
}

