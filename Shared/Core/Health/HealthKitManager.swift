import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    let store = HKHealthStore()

    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        return try await withCheckedThrowingContinuation { cont in
            store.requestAuthorization(toShare: writeTypes, read: readTypes) { ok, err in
                if let err = err { cont.resume(throwing: err); return }
                cont.resume(returning: ok)
            }
        }
    }

    private var readTypes: Set<HKObjectType> {
        var set: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]
        if let vo2 = HKObjectType.quantityType(forIdentifier: .vo2Max) { set.insert(vo2) }
        if let water = HKObjectType.quantityType(forIdentifier: .dietaryWater) { set.insert(water) }
        return set
    }

    private var writeTypes: Set<HKSampleType> { return [] }

    // MARK: - Helpers
    nonisolated func fetchSleepHoursLastNight() async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let cal = Calendar.current
        let now = Date()
        guard let start = cal.date(bySettingHour: 18, minute: 0, second: 0, of: cal.date(byAdding: .day, value: -1, to: now)!) else { return nil }
        let pred = HKQuery.predicateForSamples(withStart: start, end: now, options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, _ in
                let arr = (samples as? [HKCategorySample]) ?? []
                let asleepVals: [HKCategoryValueSleepAnalysis] = [.asleepCore, .asleepDeep, .asleepREM, .asleepUnspecified]
                let secs = arr.filter { asleepVals.contains(HKCategoryValueSleepAnalysis(rawValue: $0.value) ?? .inBed) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                cont.resume(returning: secs > 0 ? secs/3600.0 : nil)
            }
            self.store.execute(q)
        }
    }

    nonisolated func hasIntenseWorkoutToday() async -> Bool? {
        // Use active energy statistics (non-deprecated) as the primary signal
        let energy = await activeEnergyBurnedTodayKcal()
        if energy > 150 { return true }

        // Fallback: check if any workout today exceeds a duration threshold
        let type = HKObjectType.workoutType()
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: pred, limit: 10, sortDescriptors: [sort]) { _, samples, _ in
                guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else { cont.resume(returning: false); return }
                let intenseByDuration = workouts.contains { ($0.duration/60.0) > 20 }
                cont.resume(returning: intenseByDuration)
            }
            self.store.execute(q)
        }
    }

    private nonisolated func activeEnergyBurnedTodayKcal() async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return 0 }
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)
        return await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
                let val = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                cont.resume(returning: val)
            }
            self.store.execute(q)
        }
    }

    // MARK: - VO2Max and Hydration
    nonisolated func mostRecentVO2Max() async -> Double? {
        let unit = HKUnit(from: "mL/min·kg")
        return await mostRecentQuantity(.vo2Max, unit: unit)
    }

    nonisolated func averageVO2Max7d() async -> Double? {
        let unit = HKUnit(from: "mL/min·kg")
        return await averageQuantity(.vo2Max, unit: unit, last: 7)
    }

    nonisolated func waterTodayLiters() async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return 0 }
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)
        return await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
                // quantity in milliliters → convert to liters
                let ml = stats?.sumQuantity()?.doubleValue(for: HKUnit.literUnit(with: .milli)) ?? 0
                cont.resume(returning: ml / 1000.0)
            }
            self.store.execute(q)
        }
    }

    nonisolated func averageDailyWaterLiters(last days: Int = 7) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return nil }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)
        return await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
                let ml = stats?.sumQuantity()?.doubleValue(for: HKUnit.literUnit(with: .milli)) ?? 0
                let liters = ml / 1000.0
                let avg = liters / Double(days)
                cont.resume(returning: avg.isFinite ? avg : nil)
            }
            self.store.execute(q)
        }
    }

    nonisolated func mostRecentQuantity(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return nil }
        let pred = HKQuery.predicateForSamples(withStart: .distantPast, end: Date(), options: .strictEndDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: pred, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let val = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                cont.resume(returning: val)
            }
            self.store.execute(q)
        }
    }

    nonisolated func stepsByDay(last days: Int = 7) async -> [Date: Double] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return [:] }
        var interval = DateComponents(); interval.day = 1
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let anchor = Calendar.current.startOfDay(for: Date())
        return await withCheckedContinuation { cont in
            let q = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: HKQuery.predicateForSamples(withStart: start, end: Date(), options: []),
                                                options: .cumulativeSum,
                                                anchorDate: anchor,
                                                intervalComponents: interval)
            q.initialResultsHandler = { _, results, _ in
                var out: [Date: Double] = [:]
                results?.enumerateStatistics(from: start, to: Date()) { stats, _ in
                    out[stats.startDate] = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                }
                cont.resume(returning: out)
            }
            self.store.execute(q)
        }
    }

    nonisolated func hasMindfulnessToday() async -> Bool? {
        guard let type = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return nil }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: pred, limit: 1, sortDescriptors: nil) { _, samples, _ in
                cont.resume(returning: (samples?.isEmpty == false))
            }
            self.store.execute(q)
        }
    }

    // MARK: - Baselines and rich summaries
    nonisolated func averageQuantity(_ id: HKQuantityTypeIdentifier,
                                     unit: HKUnit,
                                     last days: Int = 7) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return nil }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictEndDate)
        return await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .discreteAverage) { _, stats, _ in
                let val = stats?.averageQuantity()?.doubleValue(for: unit)
                cont.resume(returning: val)
            }
            self.store.execute(q)
        }
    }

    nonisolated func averageSleepHours(last days: Int = 7) async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, _ in
                let arr = (samples as? [HKCategorySample]) ?? []
                let asleepVals: [HKCategoryValueSleepAnalysis] = [.asleepCore, .asleepDeep, .asleepREM, .asleepUnspecified]
                let secs = arr.filter { asleepVals.contains(HKCategoryValueSleepAnalysis(rawValue: $0.value) ?? .inBed) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                let avgHours = (secs / Double(days)) / 3600.0
                cont.resume(returning: avgHours.isFinite ? avgHours : nil)
            }
            self.store.execute(q)
        }
    }

    nonisolated func workoutSummaryToday() async -> (count: Int, longestMinutes: Double, totalEnergyKcal: Double) {
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
        let type = HKObjectType.workoutType()
        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let workouts = (samples as? [HKWorkout]) ?? []
                let count = workouts.count
                let longest = workouts.map { $0.duration / 60.0 }.max() ?? 0
                // Prefer non-deprecated energy via statistics function used above
                Task {
                    let kcal = await self.activeEnergyBurnedTodayKcal()
                    cont.resume(returning: (count, longest, kcal))
                }
            }
            self.store.execute(q)
        }
    }
}
