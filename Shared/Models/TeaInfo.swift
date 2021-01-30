//
//  TeaInfo.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 18.07.2020.
//

import Foundation

struct TeaInfo {
    let meta: TeaMeta
    let data: TeaData
}

struct TeaDataWithID {
    let ID: String
    let name: String
    let type: Type
    let description: String
}
