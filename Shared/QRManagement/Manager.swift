//
// Created by Andrew Khasanov on 27.01.2021.
//

import Foundation
import os
@preconcurrency import TeaElephantSchema

private let logNetwork = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Network")

enum QRCodePayload {
    static func normalize(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return trimmed
        }

        if let id = components.queryItems?.first(where: { $0.name.lowercased() == "id" })?.value,
           !id.isEmpty {
            return id
        }

        let lastPath = url.lastPathComponent
        return lastPath.isEmpty ? trimmed : lastPath
    }
}

class QRManager {
    @MainActor
    @discardableResult
    public func write(id: String, data: TeaMeta) async -> Bool {
        let normalizedID = QRCodePayload.normalize(id)
        if normalizedID.isEmpty {
            logNetwork.error("WriteMutation invalid QR id. raw=\(id, privacy: .public)")
            return false
        }
        let formatter = ISO8601DateFormatter()
        let result = await Network.shared.apollo.performAsync(mutation: WriteMutation(
            id: normalizedID,
            data: QRRecordData(tea: data.id, bowlingTemp: Int32(data.brewingTemp), expirationDate: formatter.string(from: data.expirationDate))
        ))
        switch result {
        case .success(let graphQLResult):
            if let errors = graphQLResult.errors {
                logNetwork.error("WriteMutation errors: \(String(describing: errors), privacy: .public)")
                return false
            }
            guard let id = graphQLResult.data?.writeToQR.id else {
                logNetwork.error("WriteMutation success without id")
                return false
            }
            logNetwork.info("WriteMutation success id=\(id, privacy: .public)")
            return true
        case .failure(let error):
            logNetwork.error("WriteMutation failure: \(String(describing: error), privacy: .public)")
            return false
        }
    }
}
