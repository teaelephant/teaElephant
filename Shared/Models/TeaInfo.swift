//
//  TeaInfo.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 18.07.2020.
//

import Foundation
import TeaElephantSchema

struct TeaInfo {
    let meta: TeaMeta
    let data: TeaData
    let tags: [Tag]
}

struct Tag {
    let id: String
    let name: String
    let color: String
    let category: String
}

struct TeaDataWithID {
    let ID: String
    let name: String
    let type: Type_Enum
    let description: String
}

struct Record {
    let id: String
    let data: TeaDataWithID
}
