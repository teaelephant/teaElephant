// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetQuery: GraphQLQuery {
  public static let operationName: String = "get"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query get($id: ID!) { tea(id: $id) { __typename id name type description } }"#
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
      .field("tea", Tea?.self, arguments: ["id": .variable("id")]),
    ] }

    /// Get information about tea by id.
    public var tea: Tea? { __data["tea"] }

    /// Tea
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
