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

protocol ShortInfoReader: AnyObject {
    @MainActor func startReadInfo()
    func setOnRead(_ onRead: @escaping (_ meta: TeaMeta) async -> Void)
}

@MainActor
final class Reader: ObservableObject {
    @Published var detectedInfo: TeaInfo?
    @Published var error: String?
    var extender: ExtendInfoReader
    var infoReader: ShortInfoReader
    
    init(infoReader: ShortInfoReader, extender: ExtendInfoReader) {
        self.extender = extender
        self.infoReader = infoReader
    }
    
    func readInfo() {
        infoReader.setOnRead(onReadMeta)
        infoReader.startReadInfo()
    }
    
    private func onReadMeta(_ meta: TeaMeta) async {
        do {
            let data = try await extender.getExtendInfo(id: meta.id)
            DispatchQueue.main.async {
                self.detectedInfo = TeaInfo(meta: meta, data: data, tags: [Tag]())
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
            }
        }
    }
    
    func processQRCode(_ code: String) async {
        let id = code.trimmingCharacters(in: .whitespacesAndNewlines)
        logReader.debug("Started processing QR. raw=\(code, privacy: .public), trimmed=\(id, privacy: .public)")
        if let url = URL(string: id), let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let candidate = comps.queryItems?.first(where: { $0.name == "id" })?.value ?? url.lastPathComponent
            logReader.debug("Detected URL QR payload. candidateID=\(candidate, privacy: .public)")
        }
        // Retry a few times to tolerate eventual consistency of QR writes
        let maxAttempts = 3
        for attempt in 1...maxAttempts {
            do {
                // Always fetch from network to avoid stale cache
                logReader.debug("Attempt #\(attempt) fetch read(id=\(id, privacy: .public)) with .fetchIgnoringCacheData")
                for try await result in Network.shared.apollo.fetchAsync(query: ReadQuery(id: id), cachePolicy: .fetchIgnoringCacheData) {
                    logReader.debug("Received GraphQLResult. source=\(String(describing: result.source), privacy: .public) errors=\(String(describing: result.errors), privacy: .public) hasData=\(result.data != nil, privacy: .public)")
                    if let errors = result.errors {
                        // If the error indicates free QR, retry shortly; otherwise show error
                        let mapped = self.mapErrors(errs: errors)
                        if attempt < maxAttempts, mapped == "qr code is free, write some info for this qr code first" {
                            logReader.info("Server says QR is free. Retrying soon (attempt=\(attempt))")
                            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s
                            continue
                        }
                        logReader.error("Error after fetch: \(mapped ?? "unknown", privacy: .public)")
                        self.error = mapped
                        return
                    }
                    guard let qr = result.data?.qrRecord else {
                        // Not found yet; retry
                        if attempt < maxAttempts {
                            logReader.info("qrRecord is nil. Retrying soon (attempt=\(attempt))")
                            try? await Task.sleep(nanoseconds: 800_000_000)
                            continue
                        }
                        logReader.error("qrRecord is nil. Giving up after attempt=\(attempt)")
                        return
                    }
                    
                    logReader.info("Success. tea.id=\(qr.tea.id, privacy: .public) name=\(qr.tea.name, privacy: .public) temp=\(qr.bowlingTemp, privacy: .public) exp=\(String(describing: qr.expirationDate), privacy: .public)")
                    self.detectedInfo = TeaInfo(
                        meta: TeaMeta(id: qr.tea.id, expirationDate: ISO8601DateFormatter().date(from: qr.expirationDate)!, brewingTemp: qr.bowlingTemp ),
                        data: TeaData(name: qr.tea.name, type: qr.tea.type, description: qr.tea.description),
                        tags: [Tag]()
                    )
                    return
                }
            } catch {
                logReader.error("fetch error: \(String(describing: error), privacy: .public)")
                self.error = error.localizedDescription
                return
            }
        }
        logReader.error("Exiting without result after retries")
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
