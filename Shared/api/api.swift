// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct TeaData: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - name
  ///   - type
  ///   - description
  public init(name: String, type: `Type`, description: String) {
    graphQLMap = ["name": name, "type": type, "description": description]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var type: `Type` {
    get {
      return graphQLMap["type"] as! `Type`
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  public var description: String {
    get {
      return graphQLMap["description"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }
}

public enum `Type`: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unknown
  case tea
  case coffee
  case herb
  case other
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "unknown": self = .unknown
      case "tea": self = .tea
      case "coffee": self = .coffee
      case "herb": self = .herb
      case "other": self = .other
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unknown: return "unknown"
      case .tea: return "tea"
      case .coffee: return "coffee"
      case .herb: return "herb"
      case .other: return "other"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: `Type`, rhs: `Type`) -> Bool {
    switch (lhs, rhs) {
      case (.unknown, .unknown): return true
      case (.tea, .tea): return true
      case (.coffee, .coffee): return true
      case (.herb, .herb): return true
      case (.other, .other): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [`Type`] {
    return [
      .unknown,
      .tea,
      .coffee,
      .herb,
      .other,
    ]
  }
}

public struct QRRecordData: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - tea
  ///   - bowlingTemp
  ///   - expirationDate
  public init(tea: GraphQLID, bowlingTemp: Int, expirationDate: String) {
    graphQLMap = ["tea": tea, "bowlingTemp": bowlingTemp, "expirationDate": expirationDate]
  }

  public var tea: GraphQLID {
    get {
      return graphQLMap["tea"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tea")
    }
  }

  public var bowlingTemp: Int {
    get {
      return graphQLMap["bowlingTemp"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bowlingTemp")
    }
  }

  public var expirationDate: String {
    get {
      return graphQLMap["expirationDate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expirationDate")
    }
  }
}

public final class CreateMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation create($tea: TeaData!) {
      newTea(tea: $tea) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "create"

  public var tea: TeaData

  public init(tea: TeaData) {
    self.tea = tea
  }

  public var variables: GraphQLMap? {
    return ["tea": tea]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("newTea", arguments: ["tea": GraphQLVariable("tea")], type: .nonNull(.object(NewTea.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(newTea: NewTea) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "newTea": newTea.resultMap])
    }

    public var newTea: NewTea {
      get {
        return NewTea(unsafeResultMap: resultMap["newTea"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "newTea")
      }
    }

    public struct NewTea: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Tea"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "Tea", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class WriteMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation write($id: ID!, $data: QRRecordData!) {
      writeToQR(id: $id, data: $data) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "write"

  public var id: GraphQLID
  public var data: QRRecordData

  public init(id: GraphQLID, data: QRRecordData) {
    self.id = id
    self.data = data
  }

  public var variables: GraphQLMap? {
    return ["id": id, "data": data]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("writeToQR", arguments: ["id": GraphQLVariable("id"), "data": GraphQLVariable("data")], type: .nonNull(.object(WriteToQr.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(writeToQr: WriteToQr) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "writeToQR": writeToQr.resultMap])
    }

    public var writeToQr: WriteToQr {
      get {
        return WriteToQr(unsafeResultMap: resultMap["writeToQR"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "writeToQR")
      }
    }

    public struct WriteToQr: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["QRRecord"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "QRRecord", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class GetQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query get($id: ID!) {
      getTea(id: $id) {
        __typename
        id
        name
        type
        description
      }
    }
    """

  public let operationName: String = "get"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getTea", arguments: ["id": GraphQLVariable("id")], type: .object(GetTea.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getTea: GetTea? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getTea": getTea.flatMap { (value: GetTea) -> ResultMap in value.resultMap }])
    }

    public var getTea: GetTea? {
      get {
        return (resultMap["getTea"] as? ResultMap).flatMap { GetTea(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getTea")
      }
    }

    public struct GetTea: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Tea"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(`Type`.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: String, type: `Type`, description: String) {
        self.init(unsafeResultMap: ["__typename": "Tea", "id": id, "name": name, "type": type, "description": description])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var type: `Type` {
        get {
          return resultMap["type"]! as! `Type`
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var description: String {
        get {
          return resultMap["description"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "description")
        }
      }
    }
  }
}

public final class ListQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query list($prefix: String) {
      getTeas(prefix: $prefix) {
        __typename
        id
        name
        type
        description
      }
    }
    """

  public let operationName: String = "list"

  public var `prefix`: String?

  public init(`prefix`: String? = nil) {
    self.`prefix` = `prefix`
  }

  public var variables: GraphQLMap? {
    return ["prefix": `prefix`]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getTeas", arguments: ["prefix": GraphQLVariable("prefix")], type: .nonNull(.list(.nonNull(.object(GetTea.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getTeas: [GetTea]) {
      self.init(unsafeResultMap: ["__typename": "Query", "getTeas": getTeas.map { (value: GetTea) -> ResultMap in value.resultMap }])
    }

    public var getTeas: [GetTea] {
      get {
        return (resultMap["getTeas"] as! [ResultMap]).map { (value: ResultMap) -> GetTea in GetTea(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: GetTea) -> ResultMap in value.resultMap }, forKey: "getTeas")
      }
    }

    public struct GetTea: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Tea"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(`Type`.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: String, type: `Type`, description: String) {
        self.init(unsafeResultMap: ["__typename": "Tea", "id": id, "name": name, "type": type, "description": description])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var type: `Type` {
        get {
          return resultMap["type"]! as! `Type`
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var description: String {
        get {
          return resultMap["description"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "description")
        }
      }
    }
  }
}

public final class ReadQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query read($id: ID!) {
      getQrRecord(id: $id) {
        __typename
        id
        tea {
          __typename
          id
          name
          type
          description
        }
        bowlingTemp
        expirationDate
      }
    }
    """

  public let operationName: String = "read"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getQrRecord", arguments: ["id": GraphQLVariable("id")], type: .object(GetQrRecord.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getQrRecord: GetQrRecord? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getQrRecord": getQrRecord.flatMap { (value: GetQrRecord) -> ResultMap in value.resultMap }])
    }

    public var getQrRecord: GetQrRecord? {
      get {
        return (resultMap["getQrRecord"] as? ResultMap).flatMap { GetQrRecord(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getQrRecord")
      }
    }

    public struct GetQrRecord: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["QRRecord"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("tea", type: .object(Tea.selections)),
          GraphQLField("bowlingTemp", type: .scalar(Int.self)),
          GraphQLField("expirationDate", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, tea: Tea? = nil, bowlingTemp: Int? = nil, expirationDate: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "QRRecord", "id": id, "tea": tea.flatMap { (value: Tea) -> ResultMap in value.resultMap }, "bowlingTemp": bowlingTemp, "expirationDate": expirationDate])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var tea: Tea? {
        get {
          return (resultMap["tea"] as? ResultMap).flatMap { Tea(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "tea")
        }
      }

      public var bowlingTemp: Int? {
        get {
          return resultMap["bowlingTemp"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "bowlingTemp")
        }
      }

      public var expirationDate: String? {
        get {
          return resultMap["expirationDate"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "expirationDate")
        }
      }

      public struct Tea: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Tea"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(`Type`.self))),
            GraphQLField("description", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String, type: `Type`, description: String) {
          self.init(unsafeResultMap: ["__typename": "Tea", "id": id, "name": name, "type": type, "description": description])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var type: `Type` {
          get {
            return resultMap["type"]! as! `Type`
          }
          set {
            resultMap.updateValue(newValue, forKey: "type")
          }
        }

        public var description: String {
          get {
            return resultMap["description"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }
      }
    }
  }
}
