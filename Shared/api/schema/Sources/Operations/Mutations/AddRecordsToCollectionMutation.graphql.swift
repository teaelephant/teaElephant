// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct AddRecordsToCollectionMutation: GraphQLMutation {
  public static let operationName: String = "addRecordsToCollection"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation addRecordsToCollection($id: ID!, $records: [ID!]!) { addRecordsToCollection(id: $id, records: $records) { __typename id } }"#
    ))

  public var id: ID
  public var records: [ID]

  public init(
    id: ID,
    records: [ID]
  ) {
    self.id = id
    self.records = records
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "id": id,
    "records": records
  ] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("addRecordsToCollection", AddRecordsToCollection.self, arguments: [
        "id": .variable("id"),
        "records": .variable("records")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AddRecordsToCollectionMutation.Data.self
    ] }

    /// authorization required
    public var addRecordsToCollection: AddRecordsToCollection { __data["addRecordsToCollection"] }

    /// AddRecordsToCollection
    ///
    /// Parent Type: `Collection`
    nonisolated public struct AddRecordsToCollection: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Collection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddRecordsToCollectionMutation.Data.AddRecordsToCollection.self
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
    }
  }
}
