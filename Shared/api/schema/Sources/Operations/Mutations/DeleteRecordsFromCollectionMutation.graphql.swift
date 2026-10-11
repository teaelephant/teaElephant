// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct DeleteRecordsFromCollectionMutation: GraphQLMutation {
  public static let operationName: String = "deleteRecordsFromCollection"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation deleteRecordsFromCollection($id: ID!, $records: [ID!]!) { deleteRecordsFromCollection(id: $id, records: $records) { __typename id records { __typename id } } }"#
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
      .field("deleteRecordsFromCollection", DeleteRecordsFromCollection.self, arguments: [
        "id": .variable("id"),
        "records": .variable("records")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      DeleteRecordsFromCollectionMutation.Data.self
    ] }

    /// authorization required
    public var deleteRecordsFromCollection: DeleteRecordsFromCollection { __data["deleteRecordsFromCollection"] }

    /// DeleteRecordsFromCollection
    ///
    /// Parent Type: `Collection`
    nonisolated public struct DeleteRecordsFromCollection: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Collection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
        .field("records", [Record].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeleteRecordsFromCollectionMutation.Data.DeleteRecordsFromCollection.self
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
      public var records: [Record] { __data["records"] }

      /// DeleteRecordsFromCollection.Record
      ///
      /// Parent Type: `QRRecord`
      nonisolated public struct Record: TeaElephantSchema.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", TeaElephantSchema.ID.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          DeleteRecordsFromCollectionMutation.Data.DeleteRecordsFromCollection.Record.self
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
      }
    }
  }
}
