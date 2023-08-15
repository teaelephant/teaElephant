// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateCollectionMutation: GraphQLMutation {
  public static let operationName: String = "createCollection"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation createCollection($name: String!) { createCollection(name: $name) { __typename id name records { __typename id tea { __typename id name } } } }"#
    ))

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var __variables: Variables? { ["name": name] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createCollection", CreateCollection.self, arguments: ["name": .variable("name")]),
    ] }

    /// authorization required
    public var createCollection: CreateCollection { __data["createCollection"] }

    /// CreateCollection
    ///
    /// Parent Type: `Collection`
    public struct CreateCollection: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Collection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
        .field("name", String.self),
        .field("records", [Record].self),
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var records: [Record] { __data["records"] }

      /// CreateCollection.Record
      ///
      /// Parent Type: `QRRecord`
      public struct Record: TeaElephantSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", TeaElephantSchema.ID.self),
          .field("tea", Tea.self),
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
        public var tea: Tea { __data["tea"] }

        /// CreateCollection.Record.Tea
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
          ] }

          public var id: TeaElephantSchema.ID { __data["id"] }
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
