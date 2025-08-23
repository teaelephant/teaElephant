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
    
    func fetch<Query: GraphQLQuery>(_ query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch) async throws -> Query.Data {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query, cachePolicy: cachePolicy) { result in
                switch result {
                case .success(let response):
                    if let data = response.data {
                        continuation.resume(returning: data)
                    } else if let errors = response.errors {
                        continuation.resume(throwing: AppError.graphQLErrors(errors))
                    } else {
                        continuation.resume(throwing: AppError.dataCorrupted)
                    }
                case .failure(let error):
                    continuation.resume(throwing: AppError.from(error))
                }
            }
        }
    }
    
    func perform<Mutation: GraphQLMutation>(_ mutation: Mutation) async throws -> Mutation.Data {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(mutation: mutation) { result in
                switch result {
                case .success(let response):
                    if let data = response.data {
                        continuation.resume(returning: data)
                    } else if let errors = response.errors {
                        continuation.resume(throwing: AppError.graphQLErrors(errors))
                    } else {
                        continuation.resume(throwing: AppError.dataCorrupted)
                    }
                case .failure(let error):
                    continuation.resume(throwing: AppError.from(error))
                }
            }
        }
    }
    
    func subscribe<Subscription: GraphQLSubscription>(_ subscription: Subscription) -> AnyPublisher<Subscription.Data, Error> {
        let subject = PassthroughSubject<Subscription.Data, Error>()
        
        let cancellable = apolloClient.subscribe(subscription: subscription) { result in
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
    
    func clearCache() async {
        await apolloClient.clearCache()
    }
}
