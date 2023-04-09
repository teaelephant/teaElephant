//
//  Search.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10.01.2021.
//

import Foundation
import TeaElephantSchema

protocol ApiSearcher {
    func search(prefix: String, callback: @escaping (TeaDataWithID?, Error?) -> Void)
}

class Searcher: ObservableObject {
    @Published var detectedInfo: TeaInfo?
    @Published var error: Error?
    var api: ApiSearcher

    init(_ api: ApiSearcher) {
        self.api = api
    }

    func search(prefix: String) {
        api.search(prefix: prefix) { (data, err) -> Void in
            if err != nil {
                self.detectedInfo = nil
                self.error = err
                return
            }
            self.error = nil
            if data != nil {
                self.detectedInfo = TeaInfo(
                        meta: TeaMeta(id: data!.ID, expirationDate: Date.init(), brewingTemp: 100),
                        data: TeaData(name: data!.name, type: GraphQLEnum(rawValue: data!.type.rawValue), description: data!.description)
                )
            }
        }
    }
}
