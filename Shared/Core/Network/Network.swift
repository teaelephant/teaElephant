//
//  Network.swift
//  TeaElephantEditor
//
//  Created by Andrew Khasanov on 16.01.2021.
//

import Foundation
@preconcurrency import Apollo
import ApolloAPI
import ApolloWebSocket
import KeychainSwift

enum AuthError: Error {
    case tokenNotFound
}

@MainActor
class Network {
    static let shared = Network()
    
    private func makeWebSocketTransport(token: String? = nil) -> WebSocketTransport {
        WebSocketTransport(
            urlSession: URLSession.shared,
            store: store,
            endpointURL: URL(string: "wss://tea-elephant.com/v2/query")!,
            configuration: .init(
                reconnectionInterval: 0.5,
                connectingPayload: token.map { ["Authorization": "Bearer \($0)"] }
            )
        )
    }
    
    init() {
        // Initialize WebSocket with existing token if available
        initializeWithExistingToken()
    }
    
    private func initializeWithExistingToken() {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        if let token = keychain.get(tokenKey) {
            Auth(token)
        }
    }
    
    /// A web socket transport to use for subscriptions
    private lazy var webSocketTransport: WebSocketTransport = {
        makeWebSocketTransport()
    }()
    
    func Auth(_ token: String) {
        self.webSocketTransport = makeWebSocketTransport(token: token)
        self.splitNetworkTransport = SplitNetworkTransport(
            queryTransport: normalTransport,
            mutationTransport: normalTransport,
            subscriptionTransport: webSocketTransport
        )
        self.apollo = ApolloClient(networkTransport: splitNetworkTransport, store: store)
    }
    
    func clearAuth() {
        // Reset to default transport without auth
        self.webSocketTransport = makeWebSocketTransport()
        self.splitNetworkTransport = SplitNetworkTransport(
            queryTransport: normalTransport,
            mutationTransport: normalTransport,
            subscriptionTransport: webSocketTransport
        )
        self.apollo = ApolloClient(networkTransport: splitNetworkTransport, store: store)
        
        // Clear any cached data
        let store = self.store
        Task {
            do {
                try await store.clearCache()
            } catch {
                AuthManager.shared.error = error
            }
        }
    }
    
    // The cache is necessary to set up the store, which we're going
    // to hand to the provider
    let cache = InMemoryNormalizedCache()
    private(set) lazy var store = ApolloStore(cache: cache)
    
    /// An HTTP transport to use for queries and mutations
    private lazy var normalTransport: RequestChainNetworkTransport = {
        let url = URL(string: "https://tea-elephant.com/v2/query")!
        return RequestChainNetworkTransport(
            urlSession: URLSession.shared,
            interceptorProvider: NetworkInterceptorProvider(),
            store: store,
            endpointURL: url
        )
    }()
    
    /// A split network transport to allow the use of both of the above
    /// transports through a single `NetworkTransport` instance.
    private lazy var splitNetworkTransport = SplitNetworkTransport(
        queryTransport: normalTransport,
        mutationTransport: normalTransport,
        subscriptionTransport: webSocketTransport
    )
    
    
    private(set) lazy var apollo = ApolloClient(networkTransport: splitNetworkTransport, store: store)
}

struct NetworkInterceptorProvider: InterceptorProvider {
    func httpInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any HTTPInterceptor] {
        [AuthorizationInterceptor()] + DefaultInterceptorProvider.shared.httpInterceptors(for: operation)
    }

    func graphQLInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any GraphQLInterceptor] {
        DefaultInterceptorProvider.shared.graphQLInterceptors(for: operation) + [UnauthInterceptor()]
    }

    func cacheInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> any CacheInterceptor {
        NoCachedErrorsWrapperInterceptor()
    }
}
