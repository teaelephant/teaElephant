// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class WriteMutation: GraphQLMutation {
  public static let operationName: String = "write"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation write($id: ID!, $data: QRRecordData!) {
        writeToQR(id: $id, data: $data) {
          __typename
          id
        }
      }
      """#
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

  public var __variables: Variables? { [
    "id": id,
    "data": data
  ] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("writeToQR", WriteToQR.self, arguments: [
        "id": .variable("id"),
        "data": .variable("data")
      ]),
    ] }

    public var writeToQR: WriteToQR { __data["writeToQR"] }

    /// WriteToQR
    ///
    /// Parent Type: `QRRecord`
    public struct WriteToQR: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
    }
  }
}
