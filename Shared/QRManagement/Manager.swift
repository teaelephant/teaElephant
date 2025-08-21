//
// Created by Andrew Khasanov on 27.01.2021.
//

import Foundation
import os

private let logNetwork = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Network")
import TeaElephantSchema

class QRManager {
    public func write(id: String, data: TeaMeta) async {
        let formatter = ISO8601DateFormatter()
        let result = await Network.shared.apollo.performAsync(mutation: WriteMutation(
                id: id,
                data: QRRecordData(tea: data.id, bowlingTemp: data.brewingTemp, expirationDate: formatter.string(from: data.expirationDate))
        ))
        switch result {
        case .success(let graphQLResult):
            if let errors = graphQLResult.errors {
                logNetwork.error("WriteMutation errors: \(String(describing: errors), privacy: .public)")
                return
            }
            guard let id = graphQLResult.data?.writeToQR.id else {
                return
            }
            logNetwork.info("WriteMutation success id=\(id, privacy: .public)")
        case .failure(let error):
            logNetwork.error("WriteMutation failure: \(String(describing: error), privacy: .public)")
        }
    }
}
