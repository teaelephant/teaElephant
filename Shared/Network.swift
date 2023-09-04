//
//  Network.swift
//  TeaElephantEditor
//
//  Created by Andrew Khasanov on 16.01.2021.
//

import Foundation
import Apollo
import ApolloAPI
import ApolloWebSocket

class Network {
    static let shared = Network()
    
    /// A web socket transport to use for subscriptions
    private lazy var webSocketTransport: WebSocketTransport = {
        let url = URL(string: "wss://tea-elephant.com/v2/query")!
        let webSocketClient = WebSocket(url: url, protocol: .graphql_transport_ws)
        return WebSocketTransport(websocket: webSocketClient)
    }()
    
    // The cache is necessary to set up the store, which we're going
    // to hand to the provider
    let cache = InMemoryNormalizedCache()
    private(set) lazy var store = ApolloStore(cache: cache)
    
    /// An HTTP transport to use for queries and mutations
    private lazy var normalTransport: RequestChainNetworkTransport = {
        let url = URL(string: "https://tea-elephant.com/v2/query")!
        return RequestChainNetworkTransport(interceptorProvider: NetworkInterceptorProvider(store: store, client: URLSessionClient()), endpointURL: url)
    }()
    
    /// A split network transport to allow the use of both of the above
    /// transports through a single `NetworkTransport` instance.
    private lazy var splitNetworkTransport = SplitNetworkTransport(
        uploadingNetworkTransport: normalTransport,
        webSocketNetworkTransport: webSocketTransport
    )
    
    
    private(set) lazy var apollo = ApolloClient(networkTransport: splitNetworkTransport, store: store)
}

struct NetworkInterceptorProvider: InterceptorProvider {
    
    // These properties will remain the same throughout the life of the `InterceptorProvider`, even though they
    // will be handed to different interceptors.
    private let store: ApolloStore
    private let client: URLSessionClient
    
    init(store: ApolloStore, client: URLSessionClient) {
        self.store = store
        self.client = client
    }
    
    func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        return [
            AuthorizationInterceptor(),
            MaxRetryInterceptor(),
            CacheReadInterceptor(store: self.store),
            NetworkFetchInterceptor(client: self.client),
            ResponseCodeInterceptor(),
            JSONResponseParsingInterceptor(),
            AutomaticPersistedQueryInterceptor(),
            UnauthInterceptor(),
            NoCachedErrorsWrapperInterceptor(wrapping: CacheWriteInterceptor(store: self.store)),
        ]
    }
}
