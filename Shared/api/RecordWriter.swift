//
// Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo

class RecordWriter: ExtendInfoWriter {
    func writeExtendInfo(info: TeaData, callback: @escaping (String, Error?)->()) throws {
        Network.shared.apollo.perform(mutation: CreateMutation(tea: info)) { result in

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
}
