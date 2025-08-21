//
// Created by Andrew Khasanov on 05.09.2020.
//

import Foundation
@preconcurrency import TeaElephantSchema
import Apollo

protocol ExtendInfoReader {
    func getExtendInfo(id: String) async throws -> TeaData
}

protocol ShortInfoReader {
    func startReadInfo()
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
        // Retry a few times to tolerate eventual consistency of QR writes
        let maxAttempts = 3
        for attempt in 1...maxAttempts {
            do {
                // Always fetch from network to avoid stale cache
                for try await result in Network.shared.apollo.fetchAsync(query: ReadQuery(id: id), cachePolicy: .fetchIgnoringCacheData) {
                    if let errors = result.errors {
                        // If the error indicates free QR, retry shortly; otherwise show error
                        let mapped = self.mapErrors(errs: errors)
                        if attempt < maxAttempts, mapped == "qr code is free, write some info for this qr code first" {
                            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s
                            continue
                        }
                        self.error = mapped
                        return
                    }
                    guard let qr = result.data?.qrRecord else {
                        // Not found yet; retry
                        if attempt < maxAttempts {
                            try? await Task.sleep(nanoseconds: 800_000_000)
                            continue
                        }
                        return
                    }
                    
                    self.detectedInfo = TeaInfo(
                        meta: TeaMeta(id: qr.tea.id, expirationDate: ISO8601DateFormatter().date(from: qr.expirationDate)!, brewingTemp: qr.bowlingTemp ),
                        data: TeaData(name: qr.tea.name, type: qr.tea.type, description: qr.tea.description),
                        tags: [Tag]()
                    )
                    return
                }
            } catch {
                self.error = error.localizedDescription
                return
            }
        }
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
