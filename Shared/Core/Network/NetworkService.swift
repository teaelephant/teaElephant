//
//  NetworkService.swift
//  TeaElephant
//
//  Concrete implementation of NetworkServiceProtocol wrapping Apollo
//

import Foundation
@preconcurrency import Apollo
import ApolloAPI
import Combine

@MainActor
final class NetworkService: NetworkServiceProtocol {
    private let apolloClient: ApolloClient
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    func fetch<Query: GraphQLQuery>(_ query: Query, fetchBehavior: FetchBehavior = .CacheFirst) async throws -> Query.Data {
        do {
            for try await response in apolloClient.fetchAsync(query: query, fetchBehavior: fetchBehavior) {
                if let data = response.data { return data }
                if let errors = response.errors { throw AppError.graphQLErrors(errors) }
                throw AppError.dataCorrupted
            }
            throw AppError.dataCorrupted
        } catch {
            throw AppError.from(error)
        }
    }

    func perform<Mutation: GraphQLMutation>(_ mutation: Mutation) async throws -> Mutation.Data
    where Mutation.ResponseFormat == SingleResponseFormat {
        switch await apolloClient.performAsync(mutation: mutation) {
        case .success(let response):
            if let data = response.data { return data }
            if let errors = response.errors { throw AppError.graphQLErrors(errors) }
            throw AppError.dataCorrupted
        case .failure(let error):
            throw AppError.from(error)
        }
    }

    func subscribe<Subscription: GraphQLSubscription>(_ subscription: Subscription) -> AnyPublisher<Subscription.Data, Error> {
        let subject = PassthroughSubject<Subscription.Data, Error>()
        
        let cancellable = apolloClient.subscribeAsync(subscription: subscription) { result in
            switch result {
            case .success(let response):
                if let data = response.data {
                    subject.send(data)
                } else if let errors = response.errors {
                    subject.send(completion: .failure(AppError.graphQLErrors(errors)))
                }
            case .failure(let error):
                subject.send(completion: .failure(AppError.from(error)))
            }
        }
        
        return subject
            .handleEvents(receiveCancel: {
                cancellable.cancel()
            })
            .eraseToAnyPublisher()
    }
    
    func clearCache() async throws {
        try await apolloClient.clearCache()
    }
}
