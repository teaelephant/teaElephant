// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct TeaRecommendationMutation: GraphQLMutation {
  public static let operationName: String = "teaRecommendation"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation teaRecommendation($collectionID: ID!, $feelings: String!) { teaRecommendation(collectionID: $collectionID, feelings: $feelings) }"#
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

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("teaRecommendation", String.self, arguments: [
        "collectionID": .variable("collectionID"),
        "feelings": .variable("feelings")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TeaRecommendationMutation.Data.self
    ] }

    /// get tea recommendation
    public var teaRecommendation: String { __data["teaRecommendation"] }
  }
}
