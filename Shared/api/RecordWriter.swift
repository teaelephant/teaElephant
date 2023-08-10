//
// Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo
import TeaElephantSchema

class RecordWriter: ExtendInfoWriter {
    func writeExtendInfo(info: TeaData, callback: @escaping (String, Error?)->()) async throws {
        let result = await Network.shared.apollo.performAsync(mutation: CreateMutation(tea: info))
        switch result {
        case .success(let graphQLResult):
            if let errors = graphQLResult.errors {
                callback("", errors.first)
                return
            }
            guard let id = graphQLResult.data?.newTea.id else { return }
            callback(id, nil)
        case .failure(let error):
            callback("", error)
        }
    }
}
