//
//  Search.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
@preconcurrency import Apollo
@preconcurrency import TeaElephantSchema

@MainActor
class Search: ApiSearcher {
    func search(prefix: String) async throws -> TeaDataWithID? {
        for try await result in Network.shared.apollo.fetchAsync(query: ListQuery(prefix: .some(prefix))) {
            if let errors = result.errors {
                throw errors[0]
            }
            guard let tea = result.data?.teas.first else {
                return nil
            }
            return TeaDataWithID(ID: tea.id, name: tea.name, type: tea.type.value ?? Type_Enum.unknown, description: tea.description)
        }
        return nil
    }
}
