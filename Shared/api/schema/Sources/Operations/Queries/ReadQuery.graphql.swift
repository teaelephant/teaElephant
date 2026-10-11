// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct ReadQuery: GraphQLQuery {
  public static let operationName: String = "read"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query read($id: ID!) { qrRecord(id: $id) { __typename id tea { __typename id name type description tags { __typename id color category { __typename name } name } } bowlingTemp expirationDate } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  @_spi(Unsafe) public var __variables: Variables? { ["id": id] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("qrRecord", QrRecord?.self, arguments: ["id": .variable("id")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ReadQuery.Data.self
    ] }

    /// Get tea meta information by qr code
    public var qrRecord: QrRecord? { __data["qrRecord"] }

    /// QrRecord
    ///
    /// Parent Type: `QRRecord`
    nonisolated public struct QrRecord: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
        .field("tea", Tea.self),
        .field("bowlingTemp", Int.self),
        .field("expirationDate", TeaElephantSchema.Date.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ReadQuery.Data.QrRecord.self
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
      public var tea: Tea { __data["tea"] }
      public var bowlingTemp: Int { __data["bowlingTemp"] }
      public var expirationDate: TeaElephantSchema.Date { __data["expirationDate"] }

      /// QrRecord.Tea
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
          .field("tags", [Tag].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ReadQuery.Data.QrRecord.Tea.self
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var type: GraphQLEnum<TeaElephantSchema.Type_Enum> { __data["type"] }
        public var description: String { __data["description"] }
        public var tags: [Tag] { __data["tags"] }

        /// QrRecord.Tea.Tag
        ///
        /// Parent Type: `Tag`
        nonisolated public struct Tag: TeaElephantSchema.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Tag }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", TeaElephantSchema.ID.self),
            .field("color", String.self),
            .field("category", Category.self),
            .field("name", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ReadQuery.Data.QrRecord.Tea.Tag.self
          ] }

          public var id: TeaElephantSchema.ID { __data["id"] }
          public var color: String { __data["color"] }
          public var category: Category { __data["category"] }
          public var name: String { __data["name"] }

          /// QrRecord.Tea.Tag.Category
          ///
          /// Parent Type: `TagCategory`
          nonisolated public struct Category: TeaElephantSchema.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.TagCategory }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("name", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ReadQuery.Data.QrRecord.Tea.Tag.Category.self
            ] }

            public var name: String { __data["name"] }
          }
        }
      }
    }
  }
}
