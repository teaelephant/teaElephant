//
//  ApolloClientExtension.swift
//  ApolloClientExtension
//
//  Created by Andrew Khasanov on 29.08.2021.
//

import Foundation
@preconcurrency import Apollo
@preconcurrency import TeaElephantSchema

// Wrapper to make Result Sendable
struct SendableResult<Success, Failure: Error>: @unchecked Sendable {
    let result: Result<Success, Failure>
}

extension ApolloClient {
    @preconcurrency public func fetchAsync<Query: GraphQLQuery>(query: Query,
                                                cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                                contextIdentifier: UUID? = nil,
                                                queue: DispatchQueue? = nil) -> AsyncThrowingStream<GraphQLResult<Query.Data>, Error> {
        AsyncThrowingStream { continuation in
            _ = fetch(
                        query: query,
                        cachePolicy: cachePolicy,
                        contextIdentifier: contextIdentifier,
                        queue: queue ?? .main
                    ) { response in
                        switch response {
                        case .success(let result):
                            continuation.yield(result)
                            if result.isFinalForCachePolicy(cachePolicy) {
                                continuation.finish()
                            }
                        case .failure(let error):
                            continuation.finish(throwing: error)
                        }
                    }
                }
    }
    
    nonisolated public func performAsync<Mutation: GraphQLMutation>(mutation: Mutation, publishResultToStore: Bool = true, queue: DispatchQueue = .main) async -> Result<GraphQLResult<Mutation.Data>, Error> {
        let sendableResult = await withUnsafeContinuation{ continuation in
            self.perform(mutation: mutation, publishResultToStore: publishResultToStore, queue: queue) { result in
                let wrapped = SendableResult(result: result)
                continuation.resume(returning: wrapped)
            }
        }
        return sendableResult.result
    }
    
}

fileprivate extension GraphQLResult {
    func isFinalForCachePolicy(_ cachePolicy: CachePolicy) -> Bool {
        switch cachePolicy {
        case .returnCacheDataAndFetch:
            return source == .server
        default:
            return true
        }
    }
}
