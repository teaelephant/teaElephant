// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct TeaOfTheDayQuery: GraphQLQuery {
  public static let operationName: String = "teaOfTheDay"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query teaOfTheDay { teaOfTheDay { __typename tea { __typename id bowlingTemp expirationDate tea { __typename id name description type tags { __typename id name color category { __typename name } } } } date } }"#
    ))

  public init() {}

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("teaOfTheDay", TeaOfTheDay?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TeaOfTheDayQuery.Data.self
    ] }

    /// Get tea of the day
    public var teaOfTheDay: TeaOfTheDay? { __data["teaOfTheDay"] }

    /// TeaOfTheDay
    ///
    /// Parent Type: `TeaOfTheDay`
    nonisolated public struct TeaOfTheDay: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.TeaOfTheDay }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("tea", Tea.self),
        .field("date", TeaElephantSchema.Date.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TeaOfTheDayQuery.Data.TeaOfTheDay.self
      ] }

      public var tea: Tea { __data["tea"] }
      public var date: TeaElephantSchema.Date { __data["date"] }

      /// TeaOfTheDay.Tea
      ///
      /// Parent Type: `QRRecord`
      nonisolated public struct Tea: TeaElephantSchema.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", TeaElephantSchema.ID.self),
          .field("bowlingTemp", Int.self),
          .field("expirationDate", TeaElephantSchema.Date.self),
          .field("tea", Tea.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TeaOfTheDayQuery.Data.TeaOfTheDay.Tea.self
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
        public var bowlingTemp: Int { __data["bowlingTemp"] }
        public var expirationDate: TeaElephantSchema.Date { __data["expirationDate"] }
        public var tea: Tea { __data["tea"] }

        /// TeaOfTheDay.Tea.Tea
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
            .field("description", String.self),
            .field("type", GraphQLEnum<TeaElephantSchema.Type_Enum>.self),
            .field("tags", [Tag].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TeaOfTheDayQuery.Data.TeaOfTheDay.Tea.Tea.self
          ] }

          public var id: TeaElephantSchema.ID { __data["id"] }
          public var name: String { __data["name"] }
          public var description: String { __data["description"] }
          public var type: GraphQLEnum<TeaElephantSchema.Type_Enum> { __data["type"] }
          public var tags: [Tag] { __data["tags"] }

          /// TeaOfTheDay.Tea.Tea.Tag
          ///
          /// Parent Type: `Tag`
          nonisolated public struct Tag: TeaElephantSchema.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Tag }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", TeaElephantSchema.ID.self),
              .field("name", String.self),
              .field("color", String.self),
              .field("category", Category.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TeaOfTheDayQuery.Data.TeaOfTheDay.Tea.Tea.Tag.self
            ] }

            public var id: TeaElephantSchema.ID { __data["id"] }
            public var name: String { __data["name"] }
            public var color: String { __data["color"] }
            public var category: Category { __data["category"] }

            /// TeaOfTheDay.Tea.Tea.Tag.Category
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
                TeaOfTheDayQuery.Data.TeaOfTheDay.Tea.Tea.Tag.Category.self
              ] }

              public var name: String { __data["name"] }
            }
          }
        }
      }
    }
  }
}
