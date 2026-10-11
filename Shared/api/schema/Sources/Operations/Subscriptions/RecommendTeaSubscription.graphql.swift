// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct RecommendTeaSubscription: GraphQLSubscription {
  public static let operationName: String = "recommendTea"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"subscription recommendTea($collectionID: ID!, $feelings: String!) { recommendTea(collectionID: $collectionID, feelings: $feelings) }"#
    ))

  public var collectionID: ID
  public var feelings: String

  public init(
    collectionID: ID,
    feelings: String
  ) {
    self.collectionID = collectionID
    self.feelings = feelings
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "collectionID": collectionID,
    "feelings": feelings
  ] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Subscription }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("recommendTea", String.self, arguments: [
        "collectionID": .variable("collectionID"),
        "feelings": .variable("feelings")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      RecommendTeaSubscription.Data.self
    ] }

    /// Async get tea recommendation
    public var recommendTea: String { __data["recommendTea"] }
  }
}
