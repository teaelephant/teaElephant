//
//  RecordGetter.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo

import Foundation

class RecordGetter: ExtendInfoReader {
    func getExtendInfo(id: String, callback: @escaping (TeaData?, Error?) -> Void) {
        Network.shared.apollo.fetch(query: GetQuery(id: id), resultHandler: { result in

            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    callback(nil, errors[0])
                    return
                }
                guard let tea = graphQLResult.data?.getTea else { return }
                callback(TeaData(name: tea.name, type: tea.type, description: tea.description), nil)
            case .failure(let error):
                callback(nil, error)
            }
        })
    }
}
