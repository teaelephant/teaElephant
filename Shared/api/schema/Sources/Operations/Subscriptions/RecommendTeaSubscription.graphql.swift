// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RecommendTeaSubscription: GraphQLSubscription {
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

  public var __variables: Variables? { [
    "collectionID": collectionID,
    "feelings": feelings
  ] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Subscription }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("recommendTea", String.self, arguments: [
        "collectionID": .variable("collectionID"),
        "feelings": .variable("feelings")
      ]),
    ] }

    /// Async get tea recommendation
    public var recommendTea: String { __data["recommendTea"] }
  }
}
