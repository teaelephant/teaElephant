# 🍵 Wellness‑Aware Tea Recommendations

> Feature spec for integrating wellness, sleep, and activity signals into tea recommendations on iOS.

---

## Table of Contents
- [Overview](#overview)
- [Goals](#goals)
- [Scope](#scope)
- [Data Sources](#data-sources)
  - [Apple Frameworks](#apple-frameworks)
  - [Optional Third‑Party APIs](#optional-third-party-apis)
- [Permissions & Privacy](#permissions--privacy)
- [Architecture](#architecture)
- [Implementation Steps](#implementation-steps)
- [Recommendation Logic (V1 Rules)](#recommendation-logic-v1-rules)
- [UX Surfaces](#ux-surfaces)
- [WatchOS Companion (Optional)](#watchos-companion-optional)
- [Roadmap](#roadmap)
- [Appendix: HealthKit Types](#appendix-healthkit-types)
- [Example Code](#example-code)

---

## Overview
This feature integrates wellness signals into the app to provide more personalized experiences. Initially, it will focus on helping users articulate their current state by auto-generating a descriptive text summary based on their wellness data. This text can be used in the "feelings" field when requesting a tea recommendation.

Future versions will expand on this to provide proactive tea suggestions via widgets and notifications. With user consent, the app will read data from **HealthKit** (such as sleep, workouts, and heart metrics) to power these features.

---

## Goals
- **V1 Goal:** Assist users in logging their current state by providing an auto-generated "feelings" summary based on HealthKit data.
- **Future Goals:**
    - Deliver **context‑aware** tea recommendations that feel timely and personal.
    - Increase **engagement** via widgets, Live Activities, and watch prompts.
- **Core Principle:** Keep all health data processing **on‑device** by default and remain transparent about data use.

---

## Scope
- **Platforms:** iOS (primary), optional watchOS.
- **Min iOS:** 16+ (HealthKit baseline). WorkoutKit features require iOS 18+.
- **Read only:** Health data is read; writing (e.g., hydration) is optional.

---

## Data Sources

### Apple Frameworks
- **HealthKit:** sleep, workouts, steps, active energy, HR, resting HR, HRV (SDNN), VO₂Max, mindfulness, hydration.
- **Core Motion:** lightweight step counts & motion when you don’t need full HK history.
- **WorkoutKit (iOS 18+):** build/track workouts; react to live sessions.
- **WeatherKit:** temperature/conditions to season and climate‑adjust suggestions.
- **WidgetKit & ActivityKit:** surface recs on Home/Lock Screen and as Live Activities.
- **App Intents & Shortcuts:** “Recommend a tea” / “Log my tea” voice & automation.
- **BackgroundTasks:** periodic refresh of recs while respecting power/privacy.

### Optional Third‑Party APIs
(Require OAuth + backend token storage)
- **Strava** (workouts), **Oura/WHOOP/Fitbit/Garmin/Withings** (sleep/HRV/recovery).

---

## Permissions & Privacy
- **Consent:** Explicit HealthKit authorization per data type. Clearly explain “what & why.”
- **Info.plist:**  
  - `NSHealthShareUsageDescription` (and `NSHealthUpdateUsageDescription` if writing data).
- **Data handling:** On‑device processing by default. Server sync only if the user opts in.
- **Controls:** Settings toggles per signal (Sleep, Workouts, HR/HRV, Steps, Mindfulness).
- **Transparency:** Show the top factors influencing each recommendation.

---

## Architecture
## Architecture
- **Health Layer:** `HealthKitManager` (authorization, queries, background delivery).
- **Data Store:** local cache of latest metrics + simple trends (e.g., 7‑day averages).
- **Engine:** `WellnessTextGenerator` service with a rule-based mapping from signals → descriptive strings.
- **Presentation:** A new button in `RecomendationUIView` to trigger the text generation and populate the view's `feelings` state.
- **Background:** (For future versions) Observer + Anchored queries; BackgroundTasks to coalesce updates for widgets and proactive recommendations.

---

## Implementation Steps
1. **Enable HealthKit capability** in Xcode; add Info.plist usage strings.
2. **Build `HealthKitManager`** for authorization and data queries.
3. **Create `WellnessTextGenerator`** service that takes HealthKit data and returns a formatted string.
4. **Integrate into `RecomendationUIView`**:
    - Add the "Auto-Fill Feelings" button.
    - On tap, call the new services to get the wellness string.
    - Update the `feelings` state variable with the result.
5. **Settings & privacy:**
   - Per‑signal toggles, data usage explainer, revoke/re‑request permissions.
6. **(Optional) WeatherKit:**
   - Add temperature/condition as a context feature in the text generation.

---

## Recommendation Logic (V1 Rules)

The engine will fetch data and concatenate descriptive phrases. If multiple signals are present, they are combined into a single summary string.

- **Poor/short sleep last night** *(e.g., < 6.5h or high awake time)*
  → Phrase: `"Feeling tired after a short night's sleep." `
- **Intense workout today** *(e.g., HR/energy burn above user baseline)*
  → Phrase: `"Recovering from a workout." `
- **Low HRV or elevated resting HR** *(vs. 7‑day baseline)*
  → Phrase: `"Feeling a bit stressed." `
- **Sedentary day** *(low steps vs. baseline)*
  → Phrase: `"Feeling a little sluggish." `
- **Mindfulness session logged**
  → Phrase: `"Feeling calm and mindful." `
- **Weather**
  → Hot/humid → `"It's a hot day." `
  → Cold/rainy → `"It's cool and rainy outside." `

> **Example Output:** "Feeling tired after a short night's sleep. Recovering from a workout. It's cool and rainy outside."

---

## WatchOS Companion (Optional)
- Quick actions: log tea, mark hydration, accept recommendation.
- Haptics for evening decaf reminders based on sleep schedule trends.
- Complication: “Next tea” suggestion.

---

## Roadmap
- **V1:** Implement the "Auto-Fill Feelings" button in `RecomendationUIView` using HealthKit read-only data and the rule-based text generator.
- **V2:** Implement proactive recommendations on widgets and in-app cards based on the original wellness spec, and refine settings and privacy controls.
- **V2.1:** Add watchOS companion features and optional third-party wearable integrations.

---

## Implementation Steps
1. **Enable HealthKit capability** in Xcode; add Info.plist usage strings.
2. **Request authorization** for read types (sleep, workouts, steps, HR/HRV, mindfulness, hydration).
3. **Build queries:**
   - Sleep (last 7–14 days), Workouts (recent 10), Steps (daily aggregates), HR/HRV (most recent).
4. **Background delivery:**
   - `HKObserverQuery` + `HKAnchoredObjectQuery` for incremental updates.
   - Register `BGAppRefreshTask` to periodically reconcile & refresh widgets.
5. **Recommendation engine V1:**
   - Pure functions mapping signals → tea categories; score and pick top result.
6. **Surface UI:**
   - WidgetKit small/medium cards; ActivityKit “Evening Tea Timer”; in‑app feed.
7. **Settings & privacy:**
   - Per‑signal toggles, data usage explainer, revoke/re‑request permissions.
8. **(Optional) WeatherKit:**
   - Add temperature/condition as a context feature in the scoring model.

---

## UX Surfaces

### "Auto-Fill Feelings" Button
- **Location:** `RecomendationUIView.swift`, positioned next to the `TextField` for "feelings".
- **UI:** A new `Button` with an icon (e.g., a sparkle `✨`) and/or text like "Auto-Fill".
- **Interaction:**
    1. User taps the "Auto-Fill" button.
    2. The app requests HealthKit authorization if not already granted.
    3. The `HealthKitManager` fetches the latest wellness data.
    4. A new `WellnessTextGenerator` service processes this data based on the rules below.
    5. The generated string is populated into the `feelings` state variable, updating the `TextField`.
    6. The user can review, edit, or delete the auto-filled text before submitting their recommendation request.

---

## Wellness Text Generation (V1 Rules)

The engine will fetch data and concatenate descriptive phrases. If multiple signals are present, they are combined into a single summary string.

- **Poor/short sleep last night** *(e.g., < 6.5h or high awake time)*
  → Phrase: `"Feeling tired after a short night's sleep." `
- **Intense workout today** *(e.g., HR/energy burn above user baseline)*
  → Phrase: `"Recovering from a workout." `
- **Low HRV or elevated resting HR** *(vs. 7‑day baseline)*
  → Phrase: `"Feeling a bit stressed." `
- **Sedentary day** *(low steps vs. baseline)*
  → Phrase: `"Feeling a little sluggish." `
- **Mindfulness session logged**
  → Phrase: `"Feeling calm and mindful." `
- **Weather**
  → Hot/humid → `"It's a hot day." `
  → Cold/rainy → `"It's cool and rainy outside." `

> **Example Output:** "Feeling tired after a short night's sleep. Recovering from a workout. It's cool and rainy outside."

---

## WatchOS Companion (Optional)
- Quick actions: log tea, mark hydration, accept recommendation.
- Haptics for evening decaf reminders based on sleep schedule trends.
- Complication: “Next tea” suggestion.

---

## Roadmap
- **V1:** HealthKit read + rule engine + widgets + basic backgrounds.
- **V1.1:** WeatherKit context; Settings refinements; Watch quick actions.
- **V2:** Personal baselines & lightweight ML re‑ranking on‑device.
- **V2.1:** Optional third‑party wearables (Strava/Oura/Garmin) via backend.

---

## Appendix: HealthKit Types
| Purpose | Identifier |
|---|---|
| Sleep | `HKCategoryTypeIdentifier.sleepAnalysis` |
| Workouts | `HKWorkoutType.workoutType()` |
| Steps | `HKQuantityTypeIdentifier.stepCount` |
| Active Energy | `HKQuantityTypeIdentifier.activeEnergyBurned` |
| Heart Rate | `HKQuantityTypeIdentifier.heartRate` |
| Resting HR | `HKQuantityTypeIdentifier.restingHeartRate` |
| HRV (SDNN) | `HKQuantityTypeIdentifier.heartRateVariabilitySDNN` |
| VO₂Max (optional) | `HKQuantityTypeIdentifier.vo2Max` |
| Mindfulness | `HKCategoryTypeIdentifier.mindfulSession` |
| Hydration (optional) | `HKQuantityTypeIdentifier.dietaryWater` |

---

## Example Code

### HealthKit Manager
```swift
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    let store = HKHealthStore()

    var readTypes: Set<HKObjectType> {
        var set: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]
        if let vo2 = HKObjectType.quantityType(forIdentifier: .vo2Max) { set.insert(vo2) }
        if let water = HKObjectType.quantityType(forIdentifier: .dietaryWater) { set.insert(water) }
        return set
    }

    var writeTypes: Set<HKSampleType> {
        var set = Set<HKSampleType>()
        if let water = HKObjectType.quantityType(forIdentifier: .dietaryWater) { set.insert(water) }
        if let mindful = HKObjectType.categoryType(forIdentifier: .mindfulSession) { set.insert(mindful) }
        return set
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil); return
        }
        store.requestAuthorization(toShare: writeTypes, read: readTypes, completion: completion)
    }
}
```

### Fetching Sleep (last 7 days)
```swift
func fetchSleep(completion: @escaping ([HKCategorySample]) -> Void) {
    let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
    let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, _ in
        completion(samples as? [HKCategorySample] ?? [])
    }
    HealthKitManager.shared.store.execute(query)
}
```

### Daily Steps (aggregated)
```swift
func fetchDailySteps(forLast days: Int = 7, completion: @escaping ([Date: Double]) -> Void) {
    let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    var interval = DateComponents(); interval.day = 1

    let start = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    let anchor = Calendar.current.startOfDay(for: Date())

    let query = HKStatisticsCollectionQuery(
        quantityType: type,
        quantitySamplePredicate: HKQuery.predicateForSamples(withStart: start, end: Date(), options: []),
        options: .cumulativeSum,
        anchorDate: anchor,
        intervalComponents: interval
    )

    query.initialResultsHandler = { _, results, _ in
        var out: [Date: Double] = [:]
        results?.enumerateStatistics(from: start, to: Date()) { stats, _ in
            out[stats.startDate] = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
        }
        completion(out)
    }

    HealthKitManager.shared.store.execute(query)
}
```

### Most-Recent HR / HRV
```swift
func fetchMostRecentQuantity(_ id: HKQuantityTypeIdentifier,
                             unit: HKUnit,
                             completion: @escaping (Double?) -> Void) {
    guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
        completion(nil); return
    }
    let pred = HKQuery.predicateForSamples(withStart: .distantPast, end: Date(), options: .strictEndDate)
    let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    let q = HKSampleQuery(sampleType: type, predicate: pred, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
        let qty = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
        completion(qty)
    }
    HealthKitManager.shared.store.execute(q)
}

// Usage:
fetchMostRecentQuantity(.restingHeartRate, unit: .count().unitDivided(by: .minute())) { rhr in /* … */ }
fetchMostRecentQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli)) { hrv in /* … */ }
```

### Background Delivery (observer + hourly)
```swift
func startBackgroundDelivery() {
    let toObserve: [HKObjectType] = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!
    ]

    for type in toObserve {
        let obs = HKObserverQuery(sampleType: type, predicate: nil) { _, completionHandler, _ in
            // Trigger anchored queries to fetch deltas, then update recommendations
            // ...
            completionHandler()
        }
        HealthKitManager.shared.store.execute(obs)
        HealthKitManager.shared.store.enableBackgroundDelivery(for: type, frequency: .hourly) { _, _ in }
    }
}
```

### Info.plist (usage descriptions)
```xml
<key>NSHealthShareUsageDescription</key>
<string>This app reads your health data (sleep, workouts, steps, heart metrics) to personalize tea recommendations.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app may write hydration or mindfulness logs if you choose to track them here.</string>
```

---

**Owner:** Mobile Team  
**Status:** Draft  
**Last updated:** _YYYY‑MM‑DD_
