// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct WriteMutation: GraphQLMutation {
  public static let operationName: String = "write"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation write($id: ID!, $data: QRRecordData!) { writeToQR(id: $id, data: $data) { __typename id } }"#
    ))

  public var id: ID
  public var data: QRRecordData

  public init(
    id: ID,
    data: QRRecordData
  ) {
    self.id = id
    self.data = data
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "id": id,
    "data": data
  ] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("writeToQR", WriteToQR.self, arguments: [
        "id": .variable("id"),
        "data": .variable("data")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      WriteMutation.Data.self
    ] }

    public var writeToQR: WriteToQR { __data["writeToQR"] }

    /// WriteToQR
    ///
    /// Parent Type: `QRRecord`
    nonisolated public struct WriteToQR: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        WriteMutation.Data.WriteToQR.self
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
    }
  }
}
