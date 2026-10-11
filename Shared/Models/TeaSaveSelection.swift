import Foundation
import TeaElephantSchema

enum TeaSaveTarget {
    case existing(id: String)
    case new(TeaData)
}

struct TeaSaveSelection {
    private(set) var selectedID: String?

    mutating func select(id: String) {
        selectedID = id
    }

    mutating func reset() {
        selectedID = nil
    }

    func target(name: String, type: Type_Enum, description: String) throws -> TeaSaveTarget {
        if let selectedID {
            return .existing(id: selectedID)
        }
        let error = Self.nameError(name)
        guard error.isEmpty else { throw TeaSaveValidationError.invalidName(error) }
        return .new(TeaData(name: Self.normalizedName(name), type: GraphQLEnum(type), description: description))
    }

    static func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func nameError(_ name: String) -> String {
        let name = normalizedName(name)
        if name.isEmpty { return "Name is required" }
        if name.count < 2 { return "Name must be at least 2 characters" }
        if name.count > 100 { return "Name is too long (max 100 characters)" }
        if name.rangeOfCharacter(from: .alphanumerics) == nil { return "Name must contain at least one letter or number" }
        if name.contains(where: { $0.isNewline }) { return "Name cannot contain line breaks" }
        return ""
    }
}

enum TeaSaveValidationError: LocalizedError {
    case invalidName(String)

    var errorDescription: String? {
        switch self {
        case .invalidName(let message): return message
        }
    }
}
