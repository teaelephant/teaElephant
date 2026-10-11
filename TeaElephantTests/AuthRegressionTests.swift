import XCTest
@testable import TeaElephant
import Apollo
@_spi(Unsafe) import ApolloAPI
@_spi(Unsafe) import TeaElephantSchema

final class AuthRegressionTests: XCTestCase {
    @MainActor
    func testSuccessfulPublicTeaReadDoesNotAuthenticateGuest() async throws {
        try await withIsolatedAuthState(false) {
            let response = GraphQLResponse<GetQuery>(
                data: publicTeaData(), extensions: nil, errors: nil,
                source: .server, dependentKeys: nil
            )

            let result = try await intercept(operation: GetQuery(id: "public-tea"), response: response)

            XCTAssertEqual(result.data?.tea?.id, "public-tea")
            XCTAssertFalse(TeaElephant.AuthManager.shared.auth, "A public tea response does not confirm a user session")
        }
    }

    @MainActor
    func testSuccessfulPublicQRReadDoesNotAuthenticateGuest() async throws {
        try await withIsolatedAuthState(false) {
            let response = GraphQLResponse<ReadQuery>(
                data: publicQRData(), extensions: nil, errors: nil,
                source: .server, dependentKeys: nil
            )

            let result = try await intercept(operation: ReadQuery(id: "public-qr"), response: response)

            XCTAssertEqual(result.data?.qrRecord?.id, "public-qr")
            XCTAssertFalse(TeaElephant.AuthManager.shared.auth, "A public QR response does not confirm a user session")
        }
    }

    @MainActor
    func testCachedPublicReadDoesNotAuthenticateGuest() async throws {
        try await withIsolatedAuthState(false) {
            let response = GraphQLResponse<GetQuery>(
                data: publicTeaData(), extensions: nil, errors: nil,
                source: .cache, dependentKeys: nil
            )

            let result = try await intercept(operation: GetQuery(id: "public-tea"), response: response)

            XCTAssertEqual(result.source, .cache)
            XCTAssertFalse(TeaElephant.AuthManager.shared.auth)
        }
    }

    @MainActor
    func testSuccessfulPublicReadPreservesConfirmedAuthentication() async throws {
        try await withIsolatedAuthState(true) {
            let response = GraphQLResponse<GetQuery>(
                data: publicTeaData(), extensions: nil, errors: nil,
                source: .server, dependentKeys: nil
            )

            let result = try await intercept(operation: GetQuery(id: "public-tea"), response: response)

            XCTAssertEqual(result.data?.tea?.name, "Public Green Tea")
            XCTAssertTrue(TeaElephant.AuthManager.shared.auth, "Public reads must preserve a session confirmed by the login flow")
        }
    }

    @MainActor
    func testCachedUnauthenticatedErrorDoesNotRevokeAuthentication() async throws {
        try await withIsolatedAuthState(true) {
            let response = GraphQLResponse<GetQuery>(
                data: nil, extensions: nil,
                errors: [GraphQLError(["message": "Unauthenticated", "extensions": ["code": -1]])],
                source: .cache, dependentKeys: nil
            )

            let result = try await intercept(operation: GetQuery(id: "public-tea"), response: response)

            XCTAssertEqual(result.errors?.first?.message, "Unauthenticated")
            XCTAssertTrue(TeaElephant.AuthManager.shared.auth, "Cached errors cannot revoke the current session")
        }
    }

    @MainActor
    func testUnrelatedServerErrorDoesNotRevokeAuthentication() async throws {
        try await withIsolatedAuthState(true) {
            let response = GraphQLResponse<GetQuery>(
                data: nil, extensions: nil,
                errors: [GraphQLError(["message": "Tea not found", "extensions": ["code": 404]])],
                source: .server, dependentKeys: nil
            )

            let result = try await intercept(operation: GetQuery(id: "public-tea"), response: response)

            XCTAssertEqual(result.errors?.first?.message, "Tea not found")
            XCTAssertTrue(TeaElephant.AuthManager.shared.auth)
        }
    }

    @MainActor
    func testServerUnauthenticatedErrorRevokesAuthentication() async throws {
        let errors = [
            GraphQLError(["message": "Session expired", "extensions": ["code": -1]]),
            GraphQLError(["message": "Session expired", "extensions": ["code": "-1"]]),
            GraphQLError(["message": "Session expired", "extensions": ["code": "UNAUTHENTICATED"]]),
            GraphQLError(["message": "Unauthenticated"])
        ]

        for error in errors {
            try await withIsolatedAuthState(true) {
                let response = GraphQLResponse<GetQuery>(
                    data: nil, extensions: nil, errors: [error],
                    source: .server, dependentKeys: nil
                )

                let result = try await intercept(operation: GetQuery(id: "public-tea"), response: response)

                XCTAssertEqual(result.errors?.first?.message, error.message)
                XCTAssertFalse(TeaElephant.AuthManager.shared.auth, "A server rejection must revoke authentication")
            }
        }
    }

    @MainActor
    private func withIsolatedAuthState(
        _ auth: Bool,
        body: @MainActor () async throws -> Void
    ) async rethrows {
        let manager = TeaElephant.AuthManager.shared
        let savedAuth = manager.auth
        let savedAccessGroup = manager.keychain.accessGroup
        let savedSynchronizable = manager.keychain.synchronizable
        let savedResultCode = manager.keychain.lastResultCode
        defer {
            manager.auth = savedAuth
            manager.keychain.accessGroup = savedAccessGroup
            manager.keychain.synchronizable = savedSynchronizable
            manager.keychain.lastResultCode = savedResultCode
        }

        // Every keychain query is scoped to a fresh group that has no real app items.
        // No keychain values are created, read, or cleared by this test fixture.
        manager.keychain.accessGroup = "AuthRegressionTests.\(UUID().uuidString)"
        manager.auth = auth
        try await body()
    }

    @MainActor
    private func intercept<Operation: GraphQLOperation>(
        operation: Operation,
        response: GraphQLResponse<Operation>
    ) async throws -> GraphQLResponse<Operation> {
        let request = JSONRequest(
            operation: operation,
            graphQLEndpoint: try XCTUnwrap(URL(string: "https://example.invalid/graphql")),
            fetchBehavior: .NetworkOnly,
            writeResultsToCache: false,
            requestTimeout: nil
        )
        let stream = try await TeaElephant.UnauthInterceptor().intercept(request: request) { _ in
            NonCopyableAsyncThrowingStream(stream: AsyncThrowingStream<ParsedResult<Operation>, Error> { continuation in
                continuation.yield(ParsedResult(result: response, cacheRecords: nil))
                continuation.finish()
            })
        }
        var results: [GraphQLResponse<Operation>] = []
        for try await result in stream.getStream() {
            results.append(result.result)
        }
        XCTAssertEqual(results.count, 1, "The interceptor must forward the response")
        return try XCTUnwrap(results.first)
    }

    private func publicTeaData() -> GetQuery.Data {
        let tea = GetQuery.Data.Tea(_dataDict: DataDict(
            data: [
                "__typename": "Tea",
                "id": "public-tea",
                "name": "Public Green Tea",
                "type": GraphQLEnum<Type_Enum>(.tea),
                "description": "A publicly readable tea"
            ],
            fulfilledFragments: [ObjectIdentifier(GetQuery.Data.Tea.self)]
        ))
        return GetQuery.Data(_dataDict: DataDict(
            data: ["tea": tea.__data],
            fulfilledFragments: [ObjectIdentifier(GetQuery.Data.self)]
        ))
    }

    private func publicQRData() -> ReadQuery.Data {
        let category = ReadQuery.Data.QrRecord.Tea.Tag.Category(_dataDict: DataDict(
            data: ["__typename": "TagCategory", "name": "Origin"],
            fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.Tea.Tag.Category.self)]
        ))
        let tag = ReadQuery.Data.QrRecord.Tea.Tag(_dataDict: DataDict(
            data: [
                "__typename": "Tag",
                "id": "public-tag",
                "color": "#00AA00",
                "category": category.__data,
                "name": "Japan"
            ],
            fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.Tea.Tag.self)]
        ))
        let tea = ReadQuery.Data.QrRecord.Tea(_dataDict: DataDict(
            data: [
                "__typename": "Tea",
                "id": "public-tea",
                "name": "Public Green Tea",
                "type": GraphQLEnum<Type_Enum>(.tea),
                "description": "A publicly readable tea",
                "tags": [tag.__data]
            ],
            fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.Tea.self)]
        ))
        let qr = ReadQuery.Data.QrRecord(_dataDict: DataDict(
            data: [
                "__typename": "QRRecord",
                "id": "public-qr",
                "tea": tea.__data,
                "bowlingTemp": 85,
                "expirationDate": "2026-10-11T12:00:00Z"
            ],
            fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.self)]
        ))
        return ReadQuery.Data(_dataDict: DataDict(
            data: ["qrRecord": qr.__data],
            fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.self)]
        ))
    }
}
