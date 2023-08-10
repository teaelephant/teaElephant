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
    func search(prefix: String, callback: @escaping (TeaDataWithID?, Error?) -> Void) async {
        do {
            for try await result in Network.shared.apollo.fetchAsync(query: ListQuery(prefix: .some(prefix))) {
                if let errors = result.errors {
                    callback(nil, errors[0])
                    return
                }
                guard let tea = result.data?.teas.first else { return }
                callback(TeaDataWithID(ID: tea.id, name: tea.name, type: tea.type.value ?? Type_Enum.unknown, description: tea.description), nil)
            }
        } catch {
            callback(nil, error)
        }
    }
}
