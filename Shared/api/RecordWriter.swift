//
// Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo
import TeaElephantSchema

enum WriterError: LocalizedError {
    case EmptyData
}

class RecordWriter: ExtendInfoWriter {
    func writeExtendInfo(info: TeaData) async throws -> String {
        let result = await Network.shared.apollo.performAsync(mutation: CreateMutation(tea: info))
        switch result {
        case .success(let graphQLResult):
            if let err = graphQLResult.errors?.first {
                throw err
            }
            guard let id = graphQLResult.data?.newTea.id else { throw WriterError.EmptyData  }
            return id
        case .failure(let error):
            throw error
        }
    }
}
