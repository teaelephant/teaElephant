// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ListQuery: GraphQLQuery {
  public static let operationName: String = "list"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query list($prefix: String) { teas(prefix: $prefix) { __typename id name type description } }"#
    ))

  public var prefix: GraphQLNullable<String>

  public init(prefix: GraphQLNullable<String>) {
    self.prefix = prefix
  }

  public var __variables: Variables? { ["prefix": prefix] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("teas", [Tea].self, arguments: ["prefix": .variable("prefix")]),
    ] }

    /// Get information about teas.
    public var teas: [Tea] { __data["teas"] }

    /// Tea
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
