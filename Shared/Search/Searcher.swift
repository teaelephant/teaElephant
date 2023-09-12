//
//  Search.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10.01.2021.
//

import Foundation
import TeaElephantSchema
import os

protocol ApiSearcher {
    func search(prefix: String) async throws -> TeaDataWithID?
}

class Searcher: ObservableObject {
    @Published var detectedInfo: TeaInfo?
    @Published var error: Error?
    var api: ApiSearcher
    var currentTask: Task<Void, Error>?
    let logger = Logger(subsystem: "xax.TeaElephant", category: "Searcher")
    
    init(_ api: ApiSearcher) {
        self.api = api
    }
    
    func search(prefix: String) async {
        currentTask?.cancel()
        currentTask = Task {
            try await Task.sleep(nanoseconds:500_000_000)
            guard !Task.isCancelled else { return }
            logger.debug("start search by prefix \(prefix)")
            do {
                let data = try await api.search(prefix: prefix)
                let info: TeaInfo? = {
                    if let data = data {
                        return TeaInfo(
                            meta: TeaMeta(id: data.ID, expirationDate: Date.init(), brewingTemp: 100),
                            data: TeaData(name: data.name, type: GraphQLEnum(rawValue: data.type.rawValue), description: data.description),
                            tags: [Tag]()
                        )
                    } else {
                        return nil
                    }
                }()
                
                DispatchQueue.main.async{
                    self.detectedInfo = info
                    self.error = nil
                }
            } catch {
                DispatchQueue.main.async{
                    self.detectedInfo = nil
                    self.error = error
                }
            }
        }
    }
}
