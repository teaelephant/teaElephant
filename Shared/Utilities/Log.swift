//
//  Log.swift
//  TeaElephant
//
//  Lightweight unified logging helpers for Xcode filtering.
//

import Foundation
import os

enum AppLogger {
    static let reader = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Reader")
    static let qr = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "QR")
    static let network = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Network")
    static let ui = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "UI")
}

