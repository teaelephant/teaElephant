//
//  Search.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo

class Search: ApiSearcher {
    func search(prefix: String, callback: @escaping (TeaDataWithID?, Error?) -> Void) {
        Network.shared.apollo.fetch(query: ListQuery(prefix: prefix), resultHandler: { result in

            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    callback(nil, errors[0])
                    return
                }
                guard let tea = graphQLResult.data?.getTeas.first else { return }
                callback(TeaDataWithID(ID: tea.id, name: tea.name, type: tea.type, description: tea.description), nil)
            case .failure(let error):
                callback(nil, error)
            }
        })
    }
}
