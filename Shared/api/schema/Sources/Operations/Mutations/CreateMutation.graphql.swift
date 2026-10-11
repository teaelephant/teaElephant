// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct CreateMutation: GraphQLMutation {
  public static let operationName: String = "create"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation create($tea: TeaData!) { newTea(tea: $tea) { __typename id } }"#
    ))

  public var tea: TeaData

  public init(tea: TeaData) {
    self.tea = tea
  }

  @_spi(Unsafe) public var __variables: Variables? { ["tea": tea] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("newTea", NewTea.self, arguments: ["tea": .variable("tea")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CreateMutation.Data.self
    ] }

    public var newTea: NewTea { __data["newTea"] }

    /// NewTea
    ///
    /// Parent Type: `Tea`
    nonisolated public struct NewTea: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Tea }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateMutation.Data.NewTea.self
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
    }
  }
}
