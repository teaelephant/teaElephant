// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct ListQuery: GraphQLQuery {
  public static let operationName: String = "list"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query list($prefix: String) { teas(prefix: $prefix) { __typename id name type description } }"#
    ))

  public var prefix: GraphQLNullable<String>

  public init(prefix: GraphQLNullable<String>) {
    self.prefix = prefix
  }

  @_spi(Unsafe) public var __variables: Variables? { ["prefix": prefix] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("teas", [Tea].self, arguments: ["prefix": .variable("prefix")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ListQuery.Data.self
    ] }

    /// Get information about teas.
    public var teas: [Tea] { __data["teas"] }

    /// Tea
    ///
    /// Parent Type: `Tea`
    nonisolated public struct Tea: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Tea }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
        .field("name", String.self),
        .field("type", GraphQLEnum<TeaElephantSchema.Type_Enum>.self),
        .field("description", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ListQuery.Data.Tea.self
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var type: GraphQLEnum<TeaElephantSchema.Type_Enum> { __data["type"] }
      public var description: String { __data["description"] }
    }
  }
}
