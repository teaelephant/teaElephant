//
//  TeaInfo.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 18.07.2020.
//

import Foundation

enum TeaType: String, Codable {
    case tea = "tea"
    case coffee = "coffee"
    case herb = "herb"
    case other = "other"
}

struct TeaInfo: Codable {
    let meta: TeaMeta
    let data: TeaData
}

struct TeaData: Codable {
    let name: String
    let type: TeaType
    let description: String
}
