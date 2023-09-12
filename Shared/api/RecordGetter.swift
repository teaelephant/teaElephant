//
//  RecordGetter.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo
import TeaElephantSchema

enum RecordGetterError: LocalizedError {
    case EmptyData
}

class RecordGetter: ExtendInfoReader {
    func getExtendInfo(id: String) async throws -> TeaData {
        do {
            for try await result in Network.shared.apollo.fetchAsync(query: GetQuery(id: id)) {
                if let err = result.errors?.first {
                    throw err
                }
                guard let tea = result.data?.tea else { throw RecordGetterError.EmptyData }
                return TeaData(name: tea.name, type: tea.type, description: tea.description)
            }
        } catch {
            throw error
        }
        throw RecordGetterError.EmptyData
    }
}
