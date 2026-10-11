//
// Created by Andrew Khasanov on 05.09.2020.
//

import Foundation
import os

private let logReader = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Reader")
@preconcurrency import TeaElephantSchema
@preconcurrency import Apollo

protocol ExtendInfoReader {
    @MainActor func getExtendInfo(id: String) async throws -> TeaData
}

@MainActor
protocol ShortInfoReader: AnyObject {
    func startReadInfo()
    func setOnRead(_ onRead: @escaping @MainActor (_ meta: TeaMeta) async -> Void)
    func setOnError(_ onError: @escaping @MainActor (Error) -> Void)
}

@MainActor
final class Reader: ObservableObject {
    @Published var detectedInfo: TeaInfo?
    @Published var error: String?
    var extender: ExtendInfoReader
    var infoReader: ShortInfoReader
    private let apolloClient: ApolloClient
    private var currentRead = UUID()
    
    init(infoReader: ShortInfoReader, extender: ExtendInfoReader, apolloClient: ApolloClient = Network.shared.apollo) {
        self.extender = extender
        self.infoReader = infoReader
        self.apolloClient = apolloClient
    }
    
    func readInfo() {
        let readID = beginRead()
        infoReader.setOnRead { [weak self] meta in
            await self?.onReadMeta(meta, readID: readID)
        }
        infoReader.setOnError { [weak self] error in
            guard let self, self.isCurrent(readID) else { return }
            self.error = error.localizedDescription
        }
        infoReader.startReadInfo()
    }
    
    private func onReadMeta(_ meta: TeaMeta, readID: UUID) async {
        guard isCurrent(readID) else { return }
        do {
            let data = try await extender.getExtendInfo(id: meta.id)
            guard isCurrent(readID) else { return }
            detectedInfo = TeaInfo(meta: meta, data: data, tags: [])
            error = nil
        } catch {
            guard isCurrent(readID) else { return }
            self.error = error.localizedDescription
        }
    }
    
    func processQRCode(_ code: String) async {
        guard !Task.isCancelled else { return }
        let readID = beginRead()
        let normalizedID = QRCodePayload.normalize(code)
        let trimmedID = code.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawID = code
        var candidates = [String]()
        if !normalizedID.isEmpty { candidates.append(normalizedID) }
        if trimmedID != normalizedID, !trimmedID.isEmpty { candidates.append(trimmedID) }
        if rawID != normalizedID, rawID != trimmedID, !rawID.isEmpty { candidates.append(rawID) }
        logReader.debug("Started processing QR. raw=\(code, privacy: .public), normalized=\(normalizedID, privacy: .public)")
        if candidates.isEmpty {
            self.error = "Invalid QR code. Please scan a valid tea QR code."
            return
        }
        var lastMappedError: String?
        // Retry a few times to tolerate eventual consistency of QR writes
        let maxAttempts = 3
        for candidateID in candidates {
            for attempt in 1...maxAttempts {
                guard isCurrent(readID) else { return }
                do {
                    // Always fetch from network to avoid stale cache
                    logReader.debug("Attempt #\(attempt) fetch read(id=\(candidateID, privacy: .public)) with .NetworkOnly")
                    for try await result in apolloClient.fetchAsync(query: ReadQuery(id: candidateID), fetchBehavior: .NetworkOnly) {
                        guard isCurrent(readID) else { return }
                        logReader.debug("Received GraphQLResult. source=\(String(describing: result.source), privacy: .public) errors=\(String(describing: result.errors), privacy: .public) hasData=\(result.data != nil, privacy: .public)")
                        if let errors = result.errors, !errors.isEmpty {
                            // If the error indicates free QR, retry shortly; otherwise show error
                            let mapped = self.mapErrors(errs: errors)
                            if attempt < maxAttempts, mapped == "qr code is free, write some info for this qr code first" {
                                logReader.info("Server says QR is free. Retrying soon (attempt=\(attempt))")
                                try await Task.sleep(nanoseconds: 800_000_000) // 0.8s
                                continue
                            }
                            if mapped == "qr code is free, write some info for this qr code first" {
                                lastMappedError = mapped
                                break
                            }
                            logReader.error("Error after fetch: \(mapped ?? "unknown", privacy: .public)")
                            self.error = mapped
                            return
                        }
                        guard let qr = result.data?.qrRecord else {
                            // Not found yet; retry
                            if attempt < maxAttempts {
                                logReader.info("qrRecord is nil. Retrying soon (attempt=\(attempt))")
                                try await Task.sleep(nanoseconds: 800_000_000)
                                continue
                            }
                            logReader.error("qrRecord is nil. Giving up after attempt=\(attempt)")
                            break
                        }
                        guard let expirationDate = parseExpirationDate(qr.expirationDate) else {
                            self.error = "This QR code contains an invalid expiration date."
                            return
                        }
                        
                        logReader.info("Success. tea.id=\(qr.tea.id, privacy: .public) name=\(qr.tea.name, privacy: .public) temp=\(qr.bowlingTemp, privacy: .public) exp=\(String(describing: qr.expirationDate), privacy: .public)")
                        self.detectedInfo = TeaInfo(
                            meta: TeaMeta(id: qr.tea.id, expirationDate: expirationDate, brewingTemp: qr.bowlingTemp),
                            data: TeaData(name: qr.tea.name, type: qr.tea.type, description: qr.tea.description),
                            tags: qr.tea.tags.map { Tag(id: $0.id, name: $0.name, color: $0.color, category: $0.category.name) }
                        )
                        self.error = nil
                        return
                    }
                } catch {
                    guard isCurrent(readID) else { return }
                    logReader.error("fetch error: \(String(describing: error), privacy: .public)")
                    self.error = error.localizedDescription
                    return
                }
            }
        }
        guard isCurrent(readID) else { return }
        logReader.error("Exiting without result after retries")
        self.error = lastMappedError ?? "No tea linked to this QR code yet."
    }

    private func beginRead() -> UUID {
        currentRead = UUID()
        detectedInfo = nil
        error = nil
        return currentRead
    }

    private func isCurrent(_ readID: UUID) -> Bool {
        currentRead == readID && !Task.isCancelled
    }

    private func parseExpirationDate(_ value: String) -> Foundation.Date? {
        // Foundation normalizes invalid calendar components and accepts valid prefixes.
        // Validate the backend's complete RFC 3339 wire form before parsing it.
        let pattern = #"\A[0-9]{4}-[0-9]{2}-[0-9]{2}[Tt](?:[01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](?:\.[0-9]+)?(?:[Zz]|[+-](?:[01][0-9]|2[0-3]):[0-5][0-9])\z"#
        guard value.range(of: pattern, options: .regularExpression) != nil else { return nil }
        let components = value.prefix(10).split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]), (1...12).contains(month),
              let day = Int(components[2]), day >= 1 else { return nil }
        let isLeapYear = year.isMultiple(of: 4) && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
        let monthLengths = [31, isLeapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        guard day <= monthLengths[month - 1] else { return nil }
        let normalized = value.uppercased()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: normalized) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: normalized)
    }
    
    func mapErrors(errs: [GraphQLError]) -> String? {
        guard let err = errs.first else { return nil }
        guard let code = err.extensions?["code"] as? Int else { return err.localizedDescription }
        switch code {
        case 0:
            return "qr code is free, write some info for this qr code first"
        default:
            return "unknown error"
        }
    }
}
