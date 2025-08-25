import Foundation

struct WellnessSignals {
    var sleepHoursLastNight: Double?
    var avgSleepHours7d: Double?
    var intenseWorkoutToday: Bool?
    var workoutCountToday: Int?
    var longestWorkoutMinutes: Double?
    var totalActiveEnergyKcal: Double?
    var restingHR: Double? // bpm
    var hrvSDNN: Double?   // ms
    var avgRestingHR7d: Double?
    var avgHRV7d: Double?
    var stepsToday: Double?
    var avgSteps7d: Double?
    var mindfulToday: Bool?
    var vo2Max: Double?
    var avgVO2Max7d: Double?
    var waterTodayLiters: Double?
    var avgWaterLiters7d: Double?
}

enum WellnessTextGenerator {
    static func generate(from s: WellnessSignals) -> String {
        var parts: [String] = []

        // Sleep
        if let h = s.sleepHoursLastNight {
            if let avg = s.avgSleepHours7d, avg > 0 {
                let diff = h - avg
                if diff <= -1.0 {
                    parts.append(String(format: "Slept %.1fh, ~%.1fh below your 7‑day average.", h, abs(diff)))
                } else if diff >= 1.0 {
                    parts.append(String(format: "Slept %.1fh, ~%.1fh above your average.", h, diff))
                } else {
                    parts.append(String(format: "Slept %.1fh, close to your usual.", h))
                }
            } else if h < 6.5 {
                parts.append(String(format: "Slept %.1fh — a bit short.", h))
            } else {
                parts.append(String(format: "Slept %.1fh last night.", h))
            }
        }

        // Workouts / Energy
        if let count = s.workoutCountToday, let longest = s.longestWorkoutMinutes, let kcal = s.totalActiveEnergyKcal {
            if count > 0 {
                let durationText = longest >= 10 ? String(format: "longest ~%.0f min", longest) : "short sessions"
                parts.append(String(format: "Logged %d workout%@ today (%@, ~%.0f kcal).", count, count == 1 ? "" : "s", durationText, kcal))
            } else if kcal >= 150 || (s.intenseWorkoutToday == true) {
                parts.append(String(format: "Active day (~%.0f kcal).", kcal))
            }
        } else if s.intenseWorkoutToday == true {
            parts.append("Recovering from a workout.")
        }

        // Stress proxies (HR/HRV vs baseline)
        var stressFlag = false
        if let hrv = s.hrvSDNN, let base = s.avgHRV7d, base > 0 {
            let delta = hrv - base
            if delta <= -10 { parts.append("HRV is below recent average — may feel tense."); stressFlag = true }
        }
        if let rhr = s.restingHR, let base = s.avgRestingHR7d, base > 0 {
            let delta = rhr - base
            if delta >= 5 { parts.append("Resting HR is elevated vs baseline."); stressFlag = true }
        }
        if !stressFlag {
            if let hrv = s.hrvSDNN, hrv > 0, hrv < 25 { parts.append("Feeling a bit stressed.") }
            else if let rhr = s.restingHR, rhr > 75 { parts.append("Feeling a bit stressed.") }
        }

        // Activity / Steps
        if let steps = s.stepsToday {
            if let avg = s.avgSteps7d, avg > 0 {
                let ratio = steps / avg
                if ratio <= 0.5 {
                    parts.append(String(format: "Steps today ~%.0f (below your ~%.0f avg).", steps, avg))
                } else if ratio >= 1.2 {
                    parts.append(String(format: "Great activity: ~%.0f steps (above your ~%.0f avg).", steps, avg))
                } else {
                    parts.append(String(format: "~%.0f steps so far (near your ~%.0f avg).", steps, avg))
                }
            } else {
                parts.append(String(format: "~%.0f steps so far.", steps))
            }
        }

        // Mindfulness
        if s.mindfulToday == true {
            parts.append("Logged a mindfulness session — nice reset.")
        }

        // VO₂Max (cardio fitness)
        if let v = s.vo2Max {
            if let base = s.avgVO2Max7d, base > 0 {
                let delta = v - base
                if delta <= -2 {
                    parts.append(String(format: "Cardio fitness (VO₂Max) %.1f mL/kg·min, below your avg.", v))
                } else if delta >= 2 {
                    parts.append(String(format: "Cardio fitness (VO₂Max) %.1f mL/kg·min, above recent avg.", v))
                } else {
                    parts.append(String(format: "VO₂Max ~%.1f mL/kg·min (near avg).", v))
                }
            } else {
                parts.append(String(format: "VO₂Max ~%.1f mL/kg·min.", v))
            }
        }

        // Hydration
        if let w = s.waterTodayLiters {
            if let base = s.avgWaterLiters7d, base > 0 {
                let ratio = w / base
                if ratio <= 0.6 {
                    parts.append(String(format: "Hydration today ~%.1f L (below your ~%.1f L avg).", w, base))
                } else if ratio >= 1.2 {
                    parts.append(String(format: "Well hydrated: ~%.1f L (above your ~%.1f L avg).", w, base))
                } else {
                    parts.append(String(format: "Hydration ~%.1f L (near your ~%.1f L avg).", w, base))
                }
            } else {
                parts.append(String(format: "Hydration so far ~%.1f L.", w))
            }
        }

        // Final tone
        if parts.isEmpty {
            return "Feeling okay."
        }
        return parts.joined(separator: " ")
    }
}
