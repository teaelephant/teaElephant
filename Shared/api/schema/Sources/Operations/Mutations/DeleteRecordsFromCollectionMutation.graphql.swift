// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteRecordsFromCollectionMutation: GraphQLMutation {
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

  public var __variables: Variables? { [
    "id": id,
    "records": records
  ] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("deleteRecordsFromCollection", DeleteRecordsFromCollection.self, arguments: [
        "id": .variable("id"),
        "records": .variable("records")
      ]),
    ] }

    /// authorization required
    public var deleteRecordsFromCollection: DeleteRecordsFromCollection { __data["deleteRecordsFromCollection"] }

    /// DeleteRecordsFromCollection
    ///
    /// Parent Type: `Collection`
    public struct DeleteRecordsFromCollection: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Collection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
        .field("records", [Record].self),
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
      public var records: [Record] { __data["records"] }

      /// DeleteRecordsFromCollection.Record
      ///
      /// Parent Type: `QRRecord`
      public struct Record: TeaElephantSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", TeaElephantSchema.ID.self),
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
      }
    }
  }
}
