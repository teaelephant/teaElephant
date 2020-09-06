//
//  TeaDataResponse.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 05.09.2020.
//

import Foundation

struct TeaDataResponse: Codable {
    let ID: String
    let name: String
    let type: TeaType
    let description: String
}
