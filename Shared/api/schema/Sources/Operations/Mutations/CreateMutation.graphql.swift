// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateMutation: GraphQLMutation {
  public static let operationName: String = "create"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation create($tea: TeaData!) { newTea(tea: $tea) { __typename id } }"#
    ))

  public var tea: TeaData

  public init(tea: TeaData) {
    self.tea = tea
  }

  public var __variables: Variables? { ["tea": tea] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("newTea", NewTea.self, arguments: ["tea": .variable("tea")]),
    ] }

    public var newTea: NewTea { __data["newTea"] }

    /// NewTea
    ///
    /// Parent Type: `Tea`
    public struct NewTea: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Tea }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", TeaElephantSchema.ID.self),
      ] }

      public var id: TeaElephantSchema.ID { __data["id"] }
    }
  }
}
