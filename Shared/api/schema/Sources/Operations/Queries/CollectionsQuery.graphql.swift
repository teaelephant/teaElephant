// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CollectionsQuery: GraphQLQuery {
  public static let operationName: String = "collections"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query collections { collections { __typename id name records { __typename id tea { __typename id name } } } }"#
    ))

  public init() {}

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("collections", [Collection].self),
    ] }

    /// Collection of teas, authorization required
    public var collections: [Collection] { __data["collections"] }

    /// Collection
    ///
    /// Parent Type: `Collection`
    public struct Collection: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Collection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
        .field("name", String.self),
        .field("records", [Record].self),
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var records: [Record] { __data["records"] }

      /// Collection.Record
      ///
      /// Parent Type: `QRRecord`
      public struct Record: TeaElephantSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", TeaElephantSchema.ID.self),
          .field("tea", Tea.self),
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
        public var tea: Tea { __data["tea"] }

        /// Collection.Record.Tea
        ///
        /// Parent Type: `Tea`
        public struct Tea: TeaElephantSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Tea }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", TeaElephantSchema.ID.self),
            .field("name", String.self),
          ] }

          public var id: TeaElephantSchema.ID { __data["id"] }
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
