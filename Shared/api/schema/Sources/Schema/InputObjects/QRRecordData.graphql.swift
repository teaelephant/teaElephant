// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

nonisolated public struct QRRecordData: InputObject {
  @_spi(Unsafe) public private(set) var __data: InputDict

  @_spi(Unsafe) public init(_ data: InputDict) {
    __data = data
  }

  public init(
    tea: ID,
    bowlingTemp: Int32,
    expirationDate: Date
  ) {
    __data = InputDict([
      "tea": tea,
      "bowlingTemp": bowlingTemp,
      "expirationDate": expirationDate
    ])
  }

  public var tea: ID {
    get { __data["tea"] }
    set { __data["tea"] = newValue }
  }

  public var bowlingTemp: Int32 {
    get { __data["bowlingTemp"] }
    set { __data["bowlingTemp"] = newValue }
  }

  public var expirationDate: Date {
    get { __data["expirationDate"] }
    set { __data["expirationDate"] = newValue }
  }
}
