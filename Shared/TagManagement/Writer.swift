//
// Created by Andrew Khasanov on 05.09.2020.
//

import Foundation
import TeaElephantSchema

protocol ExtendInfoWriter {
    @MainActor func writeExtendInfo(info: TeaData) async throws -> String
}

protocol ShortInfoWriter: AnyObject {
    @MainActor func writeData(info: TeaMeta) throws
}

@MainActor
class writer {
    var extend: ExtendInfoWriter
    var meta: ShortInfoWriter
    
    init(extend: ExtendInfoWriter, meta: ShortInfoWriter) {
        self.extend = extend
        self.meta = meta
    }

    func write(_ data: TeaData, expirationDate: Foundation.Date, brewingTemp: Int) async throws {
        do {
            let id = try await extend.writeExtendInfo(info: data)
            print(id)
            let meta = TeaMeta(id: id, expirationDate: expirationDate, brewingTemp: brewingTemp)
            try self.meta.writeData(info: meta)
        } catch {
            print(error)
            throw error
        }
    }
}
