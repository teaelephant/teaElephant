//
//  Collection.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 24/08/2023.
//

import Foundation

class Collection: ObservableObject {
    internal init(id: String, name: String, records: [Record]) {
        self.id = id
        self.name = name
        self.records = records
    }
    
    let id: String
    var name: String
    @Published var records: [Record]
}
