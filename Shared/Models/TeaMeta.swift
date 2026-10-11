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
        // Existing tags store a stream of three MessagePack values, without an array header.
        var reader = TeaMetaMessagePackReader(data: data)
        let id = try reader.readID()
        let expirationDate = try reader.readExpirationDate()
        let brewingTemp = try reader.readTemperature()
        guard reader.isAtEnd else {
            throw TeaMetaDecodingError.invalidPayload
        }
        return TeaMeta(id: id, expirationDate: expirationDate, brewingTemp: brewingTemp)
    }
}

private enum TeaMetaDecodingError: LocalizedError {
    case invalidPayload
    case truncatedPayload

    var errorDescription: String? {
        switch self {
        case .invalidPayload:
            return "This NFC tag does not contain valid tea information."
        case .truncatedPayload:
            return "The tea information on this NFC tag is incomplete."
        }
    }
}

private struct TeaMetaMessagePackReader {
    private let bytes: [UInt8]
    private var offset = 0

    init(data: Data) {
        bytes = Array(data)
    }

    var isAtEnd: Bool {
        offset == bytes.count
    }

    mutating func readID() throws -> String {
        let marker = try readByte()
        let count: Int
        switch marker {
        case 0xa0...0xbf:
            count = Int(marker & 0x1f)
        case 0xd9:
            count = Int(try readUnsigned(byteCount: 1))
        case 0xda:
            count = Int(try readUnsigned(byteCount: 2))
        case 0xdb:
            guard let length = Int(exactly: try readUnsigned(byteCount: 4)) else {
                throw TeaMetaDecodingError.invalidPayload
            }
            count = length
        default:
            throw TeaMetaDecodingError.invalidPayload
        }
        guard count > 0 else {
            throw TeaMetaDecodingError.invalidPayload
        }
        guard count <= bytes.count - offset else {
            throw TeaMetaDecodingError.truncatedPayload
        }
        let end = offset + count
        guard let id = String(bytes: bytes[offset..<end], encoding: .utf8) else {
            throw TeaMetaDecodingError.invalidPayload
        }
        offset = end
        return id
    }

    mutating func readExpirationDate() throws -> Date {
        guard try readByte() == 0xcb else {
            throw TeaMetaDecodingError.invalidPayload
        }
        let interval = Double(bitPattern: try readUnsigned(byteCount: 8))
        guard interval.isFinite else {
            throw TeaMetaDecodingError.invalidPayload
        }
        return Date(timeIntervalSince1970: interval)
    }

    mutating func readTemperature() throws -> Int {
        let marker = try readByte()
        let unsignedByteCount: Int
        switch marker {
        case 0x00...0x7f:
            return Int(marker)
        case 0xe0...0xff:
            return Int(Int8(bitPattern: marker))
        case 0xd0:
            return Int(Int8(bitPattern: UInt8(try readUnsigned(byteCount: 1))))
        case 0xd1:
            return Int(Int16(bitPattern: UInt16(try readUnsigned(byteCount: 2))))
        case 0xd2:
            return Int(Int32(bitPattern: UInt32(try readUnsigned(byteCount: 4))))
        case 0xd3:
            let value = Int64(bitPattern: try readUnsigned(byteCount: 8))
            guard let temperature = Int(exactly: value) else {
                throw TeaMetaDecodingError.invalidPayload
            }
            return temperature
        case 0xcc:
            unsignedByteCount = 1
        case 0xcd:
            unsignedByteCount = 2
        case 0xce:
            unsignedByteCount = 4
        case 0xcf:
            unsignedByteCount = 8
        default:
            throw TeaMetaDecodingError.invalidPayload
        }
        guard let temperature = Int(exactly: try readUnsigned(byteCount: unsignedByteCount)) else {
            throw TeaMetaDecodingError.invalidPayload
        }
        return temperature
    }

    private mutating func readByte() throws -> UInt8 {
        guard offset < bytes.count else {
            throw TeaMetaDecodingError.truncatedPayload
        }
        defer { offset += 1 }
        return bytes[offset]
    }

    private mutating func readUnsigned(byteCount: Int) throws -> UInt64 {
        guard byteCount <= bytes.count - offset else {
            throw TeaMetaDecodingError.truncatedPayload
        }
        var value: UInt64 = 0
        for _ in 0..<byteCount {
            value = (value << 8) | UInt64(bytes[offset])
            offset += 1
        }
        return value
    }
}
