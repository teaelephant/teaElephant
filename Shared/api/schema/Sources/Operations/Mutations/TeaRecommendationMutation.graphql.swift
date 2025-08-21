// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TeaRecommendationMutation: GraphQLMutation {
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

  public var __variables: Variables? { [
    "collectionID": collectionID,
    "feelings": feelings
  ] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("teaRecommendation", String.self, arguments: [
        "collectionID": .variable("collectionID"),
        "feelings": .variable("feelings")
      ]),
    ] }

    /// get tea recommendation
    public var teaRecommendation: String { __data["teaRecommendation"] }
  }
}
