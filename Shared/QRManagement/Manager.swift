//
// Created by Andrew Khasanov on 27.01.2021.
//

import Foundation
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
                print(errors)
                return
            }
            guard let id = graphQLResult.data?.writeToQR.id else {
                return
            }
            print(id)
        case .failure(let error):
            print(error)
        }
    }
}
