//
//  RecordGetter.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
@preconcurrency import Apollo
@preconcurrency import TeaElephantSchema

enum RecordGetterError: LocalizedError {
    case EmptyData
}

@MainActor
class RecordGetter: ExtendInfoReader {
    func getExtendInfo(id: String) async throws -> TeaData {
        for try await result in Network.shared.apollo.fetchAsync(query: GetQuery(id: id)) {
            if let err = result.errors?.first {
                throw err
            }
            guard let tea = result.data?.tea else { throw RecordGetterError.EmptyData }
            return TeaData(name: tea.name, type: tea.type, description: tea.description)
        }
        throw RecordGetterError.EmptyData
    }
}
