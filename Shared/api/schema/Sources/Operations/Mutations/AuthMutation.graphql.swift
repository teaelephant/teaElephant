// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct AuthMutation: GraphQLMutation {
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

  @_spi(Unsafe) public var __variables: Variables? { [
    "code": code,
    "deviceID": deviceID
  ] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("authApple", AuthApple.self, arguments: [
        "appleCode": .variable("code"),
        "deviceID": .variable("deviceID")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AuthMutation.Data.self
    ] }

    public var authApple: AuthApple { __data["authApple"] }

    /// AuthApple
    ///
    /// Parent Type: `Session`
    nonisolated public struct AuthApple: TeaElephantSchema.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Session }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("token", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AuthMutation.Data.AuthApple.self
      ] }

      public var token: String { __data["token"] }
    }
  }
}
