// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AuthMutation: GraphQLMutation {
  public static let operationName: String = "auth"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation auth($code: String!, $deviceID: ID!) { authApple(appleCode: $code, deviceID: $deviceID) { __typename token } }"#
    ))

  public var code: String
  public var deviceID: ID

  public init(
    code: String,
    deviceID: ID
  ) {
    self.code = code
    self.deviceID = deviceID
  }

  public var __variables: Variables? { [
    "code": code,
    "deviceID": deviceID
  ] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("authApple", AuthApple.self, arguments: [
        "appleCode": .variable("code"),
        "deviceID": .variable("deviceID")
      ]),
    ] }

    public var authApple: AuthApple { __data["authApple"] }

    /// AuthApple
    ///
    /// Parent Type: `Session`
    public struct AuthApple: TeaElephantSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Session }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("token", String.self),
      ] }

      public var token: String { __data["token"] }
    }
  }
}
