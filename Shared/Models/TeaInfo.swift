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
}

struct TeaDataWithID {
    let ID: String
    let name: String
    let type: Type_Enum
    let description: String
}
