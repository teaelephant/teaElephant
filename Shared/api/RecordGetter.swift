//
//  RecordGetter.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24.01.2021.
//

import Foundation
import Apollo
import TeaElephantSchema

class RecordGetter: ExtendInfoReader {
    func getExtendInfo(id: String, callback: @escaping (TeaData?, Error?) -> Void) async {
        do {
            for try await result in Network.shared.apollo.fetchAsync(query: GetQuery(id: id)) {
                if let errors = result.errors {
                    callback(nil, errors[0])
                    return
                }
                guard let tea = result.data?.tea else { return }
                callback(TeaData(name: tea.name, type: tea.type, description: tea.description), nil)
                

            }
        } catch {
            callback(nil, error)
        }
    }
}
