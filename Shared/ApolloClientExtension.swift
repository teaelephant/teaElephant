import Apollo
import ApolloAPI

extension ApolloClient {
    public func fetchAsync<Query: GraphQLQuery>(
        query: Query,
        fetchBehavior: FetchBehavior = .CacheFirst
    ) -> AsyncThrowingStream<GraphQLResponse<Query>, any Swift.Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await response in try fetch(query: query, fetchBehavior: fetchBehavior) {
                        continuation.yield(response)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }

    public func performAsync<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = true
    ) async -> Result<GraphQLResponse<Mutation>, any Swift.Error>
    where Mutation.ResponseFormat == SingleResponseFormat {
        do {
            return .success(try await perform(
                mutation: mutation,
                requestConfiguration: RequestConfiguration(writeResultsToCache: publishResultToStore)
            ))
        } catch {
            return .failure(error)
        }
    }

    public func subscribeAsync<Subscription: GraphQLSubscription>(
        subscription: Subscription,
        onResponse: @escaping @MainActor @Sendable (Result<GraphQLResponse<Subscription>, any Swift.Error>) -> Void
    ) -> Task<Void, Never> {
        Task {
            do {
                for try await response in try subscribe(subscription: subscription, cachePolicy: .networkOnly) {
                    await onResponse(.success(response))
                }
            } catch {
                if !Task.isCancelled {
                    await onResponse(.failure(error))
                }
            }
        }
    }
}
