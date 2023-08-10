// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ReadQuery: GraphQLQuery {
  public static let operationName: String = "read"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query read($id: ID!) { qrRecord(id: $id) { __typename id tea { __typename id name type description } bowlingTemp expirationDate } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("qrRecord", QrRecord?.self, arguments: ["id": .variable("id")]),
    ] }

    /// Get tea meta information by qr code
    public var qrRecord: QrRecord? { __data["qrRecord"] }

    /// QrRecord
    ///
    /// Parent Type: `QRRecord`
    public struct QrRecord: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
        .field("tea", Tea.self),
        .field("bowlingTemp", Int.self),
        .field("expirationDate", TeaElephantSchema.Date.self),
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
      public var tea: Tea { __data["tea"] }
      public var bowlingTemp: Int { __data["bowlingTemp"] }
      public var expirationDate: TeaElephantSchema.Date { __data["expirationDate"] }

      /// QrRecord.Tea
      ///
      /// Parent Type: `Tea`
      public struct Tea: TeaElephantSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Tea }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", TeaElephantSchema.ID.self),
          .field("name", String.self),
          .field("type", GraphQLEnum<TeaElephantSchema.Type_Enum>.self),
          .field("description", String.self),
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var type: GraphQLEnum<TeaElephantSchema.Type_Enum> { __data["type"] }
        public var description: String { __data["description"] }
      }
    }
  }
}
