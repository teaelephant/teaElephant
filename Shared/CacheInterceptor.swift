import Apollo
import ApolloAPI

struct NoCachedErrorsWrapperInterceptor: CacheInterceptor {
    private let wrapped: any CacheInterceptor

    init(wrapping wrapped: any CacheInterceptor = DefaultCacheInterceptor()) {
        self.wrapped = wrapped
    }

    func readCacheData<Request: GraphQLRequest>(
        from store: ApolloStore,
        request: Request
    ) async throws -> GraphQLResponse<Request.Operation>? {
        try await wrapped.readCacheData(from: store, request: request)
    }

    func writeCacheData<Request: GraphQLRequest>(
        to store: ApolloStore,
        request: Request,
        response: ParsedResult<Request.Operation>
    ) async throws {
        guard response.result.errors?.isEmpty != false else { return }
        try await wrapped.writeCacheData(to: store, request: request, response: response)
    }
}
