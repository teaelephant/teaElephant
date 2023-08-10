// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct TeaData: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    name: String,
    type: GraphQLEnum<Type_Enum>,
    description: String
  ) {
    __data = InputDict([
      "name": name,
      "type": type,
      "description": description
    ])
  }

  public var name: String {
    get { __data["name"] }
    set { __data["name"] = newValue }
  }

  public var type: GraphQLEnum<Type_Enum> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }

  public var description: String {
    get { __data["description"] }
    set { __data["description"] = newValue }
  }
}
