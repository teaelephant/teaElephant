// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RegisterDeviceMutation: GraphQLMutation {
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

  public var __variables: Variables? { [
    "deviceID": deviceID,
    "deviceToken": deviceToken
  ] }

  public struct Data: TeaElephantSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { TeaElephantSchema.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("registerDeviceToken", Bool.self, arguments: [
        "deviceID": .variable("deviceID"),
        "deviceToken": .variable("deviceToken")
      ]),
    ] }

    /// register mobile device token for notifications
    @available(*, deprecated, message: "No longer supported")
    public var registerDeviceToken: Bool { __data["registerDeviceToken"] }
  }
}
