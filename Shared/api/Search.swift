//
//  Search.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo
import TeaElephantSchema

class Search: ApiSearcher {
    func search(prefix: String, callback: @escaping (TeaDataWithID?, Error?) -> Void) {
        Network.shared.apollo.fetch(query: ListQuery(prefix: .some(prefix)), resultHandler: { result in

            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    callback(nil, errors[0])
                    return
                }
                guard let tea = graphQLResult.data?.teas.first else { return }
                callback(TeaDataWithID(ID: tea.id, name: tea.name, type: tea.type.value ?? Type.unknown, description: tea.description), nil)
            case .failure(let error):
                callback(nil, error)
            }
        })
    }
}
