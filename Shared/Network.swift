//
//  Network.swift
//  TeaElephantEditor
//
//  Created by Andrew Khasanov on 16.01.2021.
//

import Foundation
import Apollo
import ApolloWebSocket

class Network {
    static let shared = Network()

    private(set) lazy var store = ApolloStore()

    /// A web socket transport to use for subscriptions
    private lazy var webSocketTransport: WebSocketTransport = {
        let url = URL(string: "wss://te.xax.cloud/v2/query")!
        let request = URLRequest(url: url)
        return WebSocketTransport(request: request)
    }()

    /// An HTTP transport to use for queries and mutations
    private lazy var normalTransport: RequestChainNetworkTransport = {
        let url = URL(string: "https://te.xax.cloud/v2/query")!
        return RequestChainNetworkTransport(interceptorProvider: LegacyInterceptorProvider(store: store), endpointURL: url)
    }()

    /// A split network transport to allow the use of both of the above
    /// transports through a single `NetworkTransport` instance.
    private lazy var splitNetworkTransport = SplitNetworkTransport(
            uploadingNetworkTransport: normalTransport,
            webSocketNetworkTransport: webSocketTransport
    )

    private(set) lazy var apollo = ApolloClient(networkTransport: splitNetworkTransport, store: store)
}
