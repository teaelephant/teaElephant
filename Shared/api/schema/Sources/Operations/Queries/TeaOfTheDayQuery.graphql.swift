// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TeaOfTheDayQuery: GraphQLQuery {
  public static let operationName: String = "teaOfTheDay"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query teaOfTheDay { teaOfTheDay { __typename tea { __typename id bowlingTemp expirationDate tea { __typename id name description type tags { __typename id name color category { __typename name } } } } date } }"#
    ))

  public init() {}

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("teaOfTheDay", TeaOfTheDay?.self),
    ] }

    /// Get tea of the day
    public var teaOfTheDay: TeaOfTheDay? { __data["teaOfTheDay"] }

    /// TeaOfTheDay
    ///
    /// Parent Type: `TeaOfTheDay`
    public struct TeaOfTheDay: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.TeaOfTheDay }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("tea", Tea.self),
        .field("date", TeaElephantSchema.Date.self),
      ] }

      public var tea: Tea { __data["tea"] }
      public var date: TeaElephantSchema.Date { __data["date"] }

      /// TeaOfTheDay.Tea
      ///
      /// Parent Type: `QRRecord`
      public struct Tea: TeaElephantSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.QRRecord }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", TeaElephantSchema.ID.self),
          .field("bowlingTemp", Int.self),
          .field("expirationDate", TeaElephantSchema.Date.self),
          .field("tea", Tea.self),
        ] }

        public var id: TeaElephantSchema.ID { __data["id"] }
        public var bowlingTemp: Int { __data["bowlingTemp"] }
        public var expirationDate: TeaElephantSchema.Date { __data["expirationDate"] }
        public var tea: Tea { __data["tea"] }

        /// TeaOfTheDay.Tea.Tea
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
            .field("description", String.self),
            .field("type", GraphQLEnum<TeaElephantSchema.Type_Enum>.self),
            .field("tags", [Tag].self),
          ] }

          public var id: TeaElephantSchema.ID { __data["id"] }
          public var name: String { __data["name"] }
          public var description: String { __data["description"] }
          public var type: GraphQLEnum<TeaElephantSchema.Type_Enum> { __data["type"] }
          public var tags: [Tag] { __data["tags"] }

          /// TeaOfTheDay.Tea.Tea.Tag
          ///
          /// Parent Type: `Tag`
          public struct Tag: TeaElephantSchema.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Tag }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", TeaElephantSchema.ID.self),
              .field("name", String.self),
              .field("color", String.self),
              .field("category", Category.self),
            ] }

            public var id: TeaElephantSchema.ID { __data["id"] }
            public var name: String { __data["name"] }
            public var color: String { __data["color"] }
            public var category: Category { __data["category"] }

            /// TeaOfTheDay.Tea.Tea.Tag.Category
            ///
            /// Parent Type: `TagCategory`
            public struct Category: TeaElephantSchema.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.TagCategory }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("name", String.self),
              ] }

              public var name: String { __data["name"] }
            }
          }
        }
      }
    }
  }
}
