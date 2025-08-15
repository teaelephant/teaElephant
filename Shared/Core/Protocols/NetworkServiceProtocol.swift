//
//  NetworkServiceProtocol.swift
//  TeaElephant
//
//  Protocol abstraction for network operations to improve testability
//

import Foundation
import Apollo
import ApolloAPI
import Combine

protocol NetworkServiceProtocol {
    func fetch<Query: GraphQLQuery>(_ query: Query, cachePolicy: CachePolicy) async throws -> Query.Data
    func perform<Mutation: GraphQLMutation>(_ mutation: Mutation) async throws -> Mutation.Data
    func subscribe<Subscription: GraphQLSubscription>(_ subscription: Subscription) -> AnyPublisher<Subscription.Data, Error>
    func clearCache() async
}

protocol AuthenticationServiceProtocol {
    var isAuthenticated: Bool { get }
    var currentToken: String? { get }
    func setAuthToken(_ token: String)
    func clearAuthToken()
}