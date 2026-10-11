//
//  NetworkServiceProtocol.swift
//  TeaElephant
//
//  Protocol abstraction for network operations to improve testability
//

import Foundation
@preconcurrency import Apollo
import ApolloAPI
import Combine

@MainActor
protocol NetworkServiceProtocol {
    func fetch<Query: GraphQLQuery>(_ query: Query, fetchBehavior: FetchBehavior) async throws -> Query.Data
    func perform<Mutation: GraphQLMutation>(_ mutation: Mutation) async throws -> Mutation.Data where Mutation.ResponseFormat == SingleResponseFormat
    func subscribe<Subscription: GraphQLSubscription>(_ subscription: Subscription) -> AnyPublisher<Subscription.Data, Error>
    func clearCache() async throws
}

protocol AuthenticationServiceProtocol {
    var isAuthenticated: Bool { get }
    var currentToken: String? { get }
    func setAuthToken(_ token: String)
    func clearAuthToken()
}
