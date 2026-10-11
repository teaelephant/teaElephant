//
//  TeaElephantTests.swift
//  TeaElephantTests
//
//  Created by Andrew Khasanov on 16.07.2020.
//

import XCTest
@testable import TeaElephant
import SwiftUI
import Apollo
import ApolloAPI
import TeaElephantSchema

class TeaElephantTests: XCTestCase {

    @MainActor
    func testCachedResponseDoesNotRestoreAuthentication() async throws {
        let previousAuth = AuthManager.shared.auth
        defer { AuthManager.shared.auth = previousAuth }
        AuthManager.shared.auth = false
        try await processAuthResponse(source: .cache)
        XCTAssertFalse(AuthManager.shared.auth)
    }

    @MainActor
    func testPublicServerResponseDoesNotRestoreAuthentication() async throws {
        let previousAuth = AuthManager.shared.auth
        defer { AuthManager.shared.auth = previousAuth }
        AuthManager.shared.auth = false
        try await processAuthResponse(source: .server)
        XCTAssertFalse(AuthManager.shared.auth)
    }

    @MainActor
    private func processAuthResponse(source: GraphQLResponse<ListQuery>.Source) async throws {
        let request = JSONRequest(
            operation: ListQuery(prefix: .none),
            graphQLEndpoint: URL(string: "https://example.invalid/graphql")!,
            fetchBehavior: .CacheFirst,
            writeResultsToCache: true,
            requestTimeout: nil
        )
        let response = GraphQLResponse<ListQuery>(data: nil, extensions: nil, errors: nil, source: source, dependentKeys: nil)
        let stream = try await UnauthInterceptor().intercept(request: request) { _ in
            NonCopyableAsyncThrowingStream(stream: AsyncThrowingStream<ParsedResult<ListQuery>, Error> { continuation in
                continuation.yield(ParsedResult(result: response, cacheRecords: nil))
                continuation.finish()
            })
        }
        for try await _ in stream.getStream() {}
    }

    func testAuthorizationInterceptorAddsBearerToken() async throws {
        let interceptor = AuthorizationInterceptor(tokenProvider: { "synthetic-token" })
        let request = URLRequest(url: URL(string: "https://example.invalid/graphql")!)
        do {
            _ = try await interceptor.intercept(request: request) { request in
                XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer synthetic-token")
                throw InterceptorProbe.requestCaptured
            }
            XCTFail("Expected the test transport to stop the request")
        } catch InterceptorProbe.requestCaptured {}
    }

    func testAuthorizationInterceptorLeavesAnonymousRequestsWithoutToken() async throws {
        let interceptor = AuthorizationInterceptor(tokenProvider: { nil })
        let request = URLRequest(url: URL(string: "https://example.invalid/graphql")!)
        do {
            _ = try await interceptor.intercept(request: request) { request in
                XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
                throw InterceptorProbe.requestCaptured
            }
            XCTFail("Expected the test transport to stop the request")
        } catch InterceptorProbe.requestCaptured {}
    }

    func testCacheInterceptorDoesNotWriteGraphQLErrors() async throws {
        let wrapped = CacheProbe()
        let interceptor = NoCachedErrorsWrapperInterceptor(wrapping: wrapped)
        let request = JSONRequest(
            operation: ListQuery(prefix: .none),
            graphQLEndpoint: URL(string: "https://example.invalid/graphql")!,
            fetchBehavior: .NetworkOnly,
            writeResultsToCache: true,
            requestTimeout: nil
        )
        let store = ApolloStore()
        let success = GraphQLResponse<ListQuery>(data: nil, extensions: nil, errors: nil, source: .server, dependentKeys: nil)
        let failure = GraphQLResponse<ListQuery>(data: nil, extensions: nil, errors: [GraphQLError(["message": "Synthetic error"])], source: .server, dependentKeys: nil)
        try await interceptor.writeCacheData(to: store, request: request, response: ParsedResult(result: success, cacheRecords: nil))
        try await interceptor.writeCacheData(to: store, request: request, response: ParsedResult(result: failure, cacheRecords: nil))
        _ = try await interceptor.readCacheData(from: store, request: request)
        let counts = await wrapped.counts
        XCTAssertEqual(counts.reads, 1)
        XCTAssertEqual(counts.writes, 1)
    }

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testprocessQRCode() async throws {
        let client = ApolloClient(networkTransport: FreeQRTransport(), store: ApolloStore())
        let reader = Reader(infoReader: NFCReader(), extender: RecordGetter(), apolloClient: client)
        await reader.processQRCode("3c252497-9d87-44f0-b3de-2822c6b94df5")
        XCTAssertEqual(
            reader.error,
            "qr code is free, write some info for this qr code first",
            "incorrect error"
        )
    }
    
    func testColorIsDark() {
        let colorview = Color(hex: "#BE000000")
        XCTAssertTrue(colorview.isDark())
    }
    
    func testColorIsDarkNegative() {
        let colorview = Color(hex: "#FFFFFFFF")
        XCTAssertFalse(colorview.isDark())
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

private enum InterceptorProbe: Error {
    case requestCaptured
}

private final class FreeQRTransport: NetworkTransport {
    func send<Query: GraphQLQuery>(query: Query, fetchBehavior: FetchBehavior, requestConfiguration: RequestConfiguration) throws -> AsyncThrowingStream<GraphQLResponse<Query>, Error> {
        AsyncThrowingStream { continuation in
            let error = GraphQLError(["message": "Free QR code", "extensions": ["code": 0]])
            continuation.yield(GraphQLResponse(data: nil, extensions: nil, errors: [error], source: .server, dependentKeys: nil))
            continuation.finish()
        }
    }

    func send<Mutation: GraphQLMutation>(mutation: Mutation, requestConfiguration: RequestConfiguration) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, Error> {
        throw URLError(.unsupportedURL)
    }
}

private actor CacheProbe: CacheInterceptor {
    private var reads = 0
    private var writes = 0
    var counts: (reads: Int, writes: Int) { (reads, writes) }

    func readCacheData<Request: GraphQLRequest>(from store: ApolloStore, request: Request) async throws -> GraphQLResponse<Request.Operation>? {
        reads += 1
        return nil
    }

    func writeCacheData<Request: GraphQLRequest>(to store: ApolloStore, request: Request, response: ParsedResult<Request.Operation>) async throws {
        writes += 1
    }
}
