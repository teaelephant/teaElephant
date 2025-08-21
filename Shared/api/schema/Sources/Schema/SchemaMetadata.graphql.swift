// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == TeaElephantSchema.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == TeaElephantSchema.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == TeaElephantSchema.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == TeaElephantSchema.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Collection": return TeaElephantSchema.Objects.Collection
    case "Mutation": return TeaElephantSchema.Objects.Mutation
    case "QRRecord": return TeaElephantSchema.Objects.QRRecord
    case "Query": return TeaElephantSchema.Objects.Query
    case "Session": return TeaElephantSchema.Objects.Session
    case "Subscription": return TeaElephantSchema.Objects.Subscription
    case "Tag": return TeaElephantSchema.Objects.Tag
    case "TagCategory": return TeaElephantSchema.Objects.TagCategory
    case "Tea": return TeaElephantSchema.Objects.Tea
    case "TeaOfTheDay": return TeaElephantSchema.Objects.TeaOfTheDay
    case "User": return TeaElephantSchema.Objects.User
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
