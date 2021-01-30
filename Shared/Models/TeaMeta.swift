//
//  TeaMeta.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 02.08.2020.
//

import Foundation
import MessagePacker

struct TeaMeta: Codable {
    let id: String
    let expirationDate: Date
    let brewingTemp: Int
}

extension TeaMeta {
    func toBytes() throws -> Data {
        var data: Data
        let encoder = MessagePackEncoder()
        do {
            data = try encoder.encode(id)
            print(data.count)
            data.append(try encoder.encode(expirationDate.timeIntervalSince1970))
            print(data.count)
            data.append(try encoder.encode(brewingTemp))
            print(data.count)
        } catch {
            print(error.localizedDescription)
            throw error
        }
        return data
    }
    static func fromBytes(data: Data) throws -> Self {
        let decoder = MessagePackDecoder()
        do {
            let id = try decoder.decode(String.self, from: data[..<38])
            let expirationDate = try decoder.decode(TimeInterval.self, from: data[38..<47])
            let brewingTemp = try decoder.decode(Int.self, from: data[47..<48])
            return TeaMeta(id: id, expirationDate: Date(timeIntervalSince1970: expirationDate), brewingTemp:brewingTemp)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
