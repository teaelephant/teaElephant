// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct RegisterDeviceMutation: GraphQLMutation {
  public static let operationName: String = "registerDevice"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation registerDevice($deviceID: ID!, $deviceToken: String!) { registerDeviceToken(deviceID: $deviceID, deviceToken: $deviceToken) }"#
    ))

  public var deviceID: ID
  public var deviceToken: String

  public init(
    deviceID: ID,
    deviceToken: String
  ) {
    self.deviceID = deviceID
    self.deviceToken = deviceToken
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "deviceID": deviceID,
    "deviceToken": deviceToken
  ] }

  nonisolated public struct Data: TeaElephantSchema.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("registerDeviceToken", Bool.self, arguments: [
        "deviceID": .variable("deviceID"),
        "deviceToken": .variable("deviceToken")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      RegisterDeviceMutation.Data.self
    ] }

    /// register mobile device token for notifications
    @available(*, deprecated, message: "No longer supported")
    public var registerDeviceToken: Bool { __data["registerDeviceToken"] }
  }
}
