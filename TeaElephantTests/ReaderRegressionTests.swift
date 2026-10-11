import XCTest
@testable import TeaElephant
import Apollo
@_spi(Unsafe) import ApolloAPI
@_spi(Unsafe) import TeaElephantSchema

private let qrID = "3c252497-9d87-44f0-b3de-2822c6b94df5"

final class ReaderRegressionTests: XCTestCase {
    @MainActor
    func testSuccessfulQRReadClearsPreviousError() async {
        let reader = makeReader()
        reader.error = "Previous scan failed"
        await reader.processQRCode(qrID)
        XCTAssertNotNil(reader.detectedInfo)
        XCTAssertNil(reader.error)
    }

    @MainActor
    func testFailedQRReadClearsPreviousTea() async {
        let reader = makeReader()
        await reader.processQRCode(qrID)
        XCTAssertEqual(reader.detectedInfo?.meta.id, "regression-tea")
        await reader.processQRCode("missing-qr")
        XCTAssertNotNil(reader.error)
        XCTAssertNil(reader.detectedInfo)
    }

    @MainActor
    func testEmptyQRReadClearsPreviousTea() async {
        let reader = makeReader()
        await reader.processQRCode(qrID)
        await reader.processQRCode(" \n ")
        XCTAssertNotNil(reader.error)
        XCTAssertNil(reader.detectedInfo)
    }

    @MainActor
    func testQRReadPreservesTagsAndCategories() async {
        let reader = makeReader()
        await reader.processQRCode(qrID)
        XCTAssertEqual(reader.detectedInfo?.tags.count, 1)
        XCTAssertEqual(reader.detectedInfo?.tags.first?.id, "origin-japan")
        XCTAssertEqual(reader.detectedInfo?.tags.first?.name, "Japan")
        XCTAssertEqual(reader.detectedInfo?.tags.first?.color, "#00AA00")
        XCTAssertEqual(reader.detectedInfo?.tags.first?.category, "Origin")
    }

    @MainActor
    func testWholeSecondExpirationDateIsSupported() async {
        let reader = makeReader(expiration: "2026-10-11T12:00:00Z")
        await reader.processQRCode(qrID)
        XCTAssertNil(reader.error)
        XCTAssertEqual(reader.detectedInfo?.meta.expirationDate.timeIntervalSince1970, 1_791_720_000)
    }

    @MainActor
    func testNFCReaderOwnerIsReleasedAfterStartingRead() async {
        weak var released: TeaElephant.Reader?
        do {
            let reader = makeReader()
            released = reader
            reader.readInfo()
        }
        await Task.yield()
        XCTAssertNil(released)
    }

    @MainActor
    func testPendingReadCallbackDoesNotRetainOwner() {
        let input = RetainingInfoReader()
        weak var released: TeaElephant.Reader?
        do {
            let reader = TeaElephant.Reader(infoReader: input, extender: TeaElephant.RecordGetter())
            released = reader
            reader.readInfo()
        }
        XCTAssertNotNil(input.callback)
        XCTAssertNil(released)
    }

    @MainActor
    func testStartingNFCReadClearsPreviousState() async {
        let input = RetainingInfoReader()
        let client = ApolloClient(networkTransport: ReaderFixtureTransport(id: qrID, data: makeQRData()), store: ApolloStore())
        let reader = TeaElephant.Reader(infoReader: input, extender: TeaElephant.RecordGetter(), apolloClient: client)
        await reader.processQRCode(qrID)
        reader.error = "Previous read failed"
        reader.readInfo()
        XCTAssertNil(reader.detectedInfo)
        XCTAssertNil(reader.error)
        input.errorCallback?(URLError(.cannotParseResponse))
        XCTAssertNotNil(reader.error)
    }

    @MainActor
    func testOlderQRResultCannotReplaceNewerRead() async {
        let oldID = qrID
        let newID = "2591882e-69c2-4c48-8fcf-14c71872f895"
        let oldStarted = expectation(description: "Older request started")
        let newStarted = expectation(description: "Newer request started")
        let transport = ControlledReaderTransport { id in
            if id == oldID { oldStarted.fulfill() }
            if id == newID { newStarted.fulfill() }
        }
        let client = ApolloClient(networkTransport: transport, store: ApolloStore())
        let reader = TeaElephant.Reader(infoReader: RetainingInfoReader(), extender: TeaElephant.RecordGetter(), apolloClient: client)

        let oldRead = Task { await reader.processQRCode(oldID) }
        defer { oldRead.cancel() }
        await fulfillment(of: [oldStarted], timeout: 5)
        let newRead = Task { await reader.processQRCode(newID) }
        defer { newRead.cancel() }
        await fulfillment(of: [newStarted], timeout: 5)

        transport.complete(id: newID, data: makeQRData(teaID: "newer-tea"))
        await newRead.value
        XCTAssertEqual(reader.detectedInfo?.meta.id, "newer-tea")
        transport.complete(id: oldID, data: makeQRData(teaID: "older-tea"))
        await oldRead.value
        XCTAssertEqual(reader.detectedInfo?.meta.id, "newer-tea")
        XCTAssertNil(reader.error)
    }

    @MainActor
    func testCancelledQRReadDoesNotPublishAnError() async {
        let started = expectation(description: "QR request started")
        let transport = ControlledReaderTransport { _ in started.fulfill() }
        let client = ApolloClient(networkTransport: transport, store: ApolloStore())
        let reader = TeaElephant.Reader(infoReader: RetainingInfoReader(), extender: TeaElephant.RecordGetter(), apolloClient: client)
        let read = Task { await reader.processQRCode(qrID) }
        await fulfillment(of: [started], timeout: 5)
        read.cancel()
        await read.value
        XCTAssertNil(reader.detectedInfo)
        XCTAssertNil(reader.error)
    }

    @MainActor
    func testEarlierNFCFailureCannotOverwriteLaterQRRead() async throws {
        let started = expectation(description: "NFC tea request started")
        let extender = DeferredExtender { started.fulfill() }
        let input = RetainingInfoReader()
        let client = ApolloClient(networkTransport: ReaderFixtureTransport(id: qrID, data: makeQRData()), store: ApolloStore())
        let reader = TeaElephant.Reader(infoReader: input, extender: extender, apolloClient: client)
        reader.readInfo()
        let callback = try XCTUnwrap(input.callback)
        let nfcRead = Task { await callback(TeaElephant.TeaMeta(id: "earlier-nfc", expirationDate: Date(timeIntervalSince1970: 0), brewingTemp: 85)) }
        await fulfillment(of: [started], timeout: 5)
        await reader.processQRCode(qrID)
        extender.fail()
        await nfcRead.value
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
        XCTAssertEqual(reader.detectedInfo?.meta.id, "regression-tea")
        XCTAssertNil(reader.error)
    }
}

@MainActor
private func makeReader(expiration: String = "2026-10-11T12:00:00Z") -> TeaElephant.Reader {
    let client = ApolloClient(networkTransport: ReaderFixtureTransport(id: qrID, data: makeQRData(expiration: expiration)), store: ApolloStore())
    return TeaElephant.Reader(infoReader: TeaElephant.NFCReader(), extender: TeaElephant.RecordGetter(), apolloClient: client)
}

private func makeQRData(teaID: String = "regression-tea", expiration: String = "2026-10-11T12:00:00Z") -> ReadQuery.Data {
    let category = ReadQuery.Data.QrRecord.Tea.Tag.Category(_dataDict: DataDict(
        data: ["__typename": "TagCategory", "name": "Origin"],
        fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.Tea.Tag.Category.self)]
    ))
    let tag = ReadQuery.Data.QrRecord.Tea.Tag(_dataDict: DataDict(
        data: ["__typename": "Tag", "id": "origin-japan", "color": "#00AA00", "name": "Japan", "category": category.__data],
        fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.Tea.Tag.self)]
    ))
    let tea = ReadQuery.Data.QrRecord.Tea(_dataDict: DataDict(
        data: ["__typename": "Tea", "id": teaID, "name": "Green Tea", "type": GraphQLEnum<Type_Enum>(.tea), "description": "Synthetic tea", "tags": [tag.__data]],
        fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.Tea.self)]
    ))
    let qr = ReadQuery.Data.QrRecord(_dataDict: DataDict(
        data: ["__typename": "QRRecord", "id": qrID, "tea": tea.__data, "bowlingTemp": 85, "expirationDate": expiration],
        fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.QrRecord.self)]
    ))
    return ReadQuery.Data(_dataDict: DataDict(
        data: ["qrRecord": qr.__data],
        fulfilledFragments: [ObjectIdentifier(ReadQuery.Data.self)]
    ))
}

final class QRDateRegressionTests: XCTestCase {
    @MainActor
    func testFractionalExpirationDateIsSupported() async throws {
        let reader = makeReader(expiration: "2026-10-11T12:00:00.123Z")
        await reader.processQRCode("3c252497-9d87-44f0-b3de-2822c6b94df5")
        XCTAssertNil(reader.error)
        let date = try XCTUnwrap(reader.detectedInfo?.meta.expirationDate)
        XCTAssertEqual(date.timeIntervalSince1970, 1_791_720_000.123, accuracy: 0.001)
    }

    @MainActor
    func testNanosecondExpirationDateWithOffsetIsSupported() async throws {
        let reader = makeReader(expiration: "2026-10-11T14:00:00.123456789+02:00")
        await reader.processQRCode("3c252497-9d87-44f0-b3de-2822c6b94df5")
        XCTAssertNil(reader.error)
        let date = try XCTUnwrap(reader.detectedInfo?.meta.expirationDate)
        XCTAssertEqual(date.timeIntervalSince1970, 1_791_720_000.123456789, accuracy: 0.001)
    }

    @MainActor
    func testMalformedExpirationDateBecomesAReadError() async {
        let reader = makeReader(expiration: "not-a-date")
        await reader.processQRCode("3c252497-9d87-44f0-b3de-2822c6b94df5")
        XCTAssertNil(reader.detectedInfo)
        XCTAssertNotNil(reader.error)
    }

    @MainActor
    func testInvalidCalendarDatesAndTrailingTextAreRejected() async {
        let invalidDates = [
            "2026-02-30T12:00:00Z",
            "2025-02-29T12:00:00Z",
            "2026-10-11T24:00:00Z",
            "2026-10-11T12:00:00+24:00",
            "2026-10-11T12:00:00+02:60",
            "2026-13-11T12:00:00Z",
            "2026-10-00T12:00:00Z",
            "2026-10-11T12:00:00Zgarbage",
            "2026-10-11T12:00:00Z\n"
        ]
        for expiration in invalidDates {
            let reader = makeReader(expiration: expiration)
            await reader.processQRCode(qrID)
            XCTAssertNil(reader.detectedInfo, expiration)
            XCTAssertNotNil(reader.error, expiration)
        }
    }

    @MainActor
    func testLeapDayAndLowercaseTimestampsAreSupported() async {
        let leapDay = makeReader(expiration: "2024-02-29T12:00:00Z")
        await leapDay.processQRCode(qrID)
        XCTAssertNil(leapDay.error)
        XCTAssertEqual(leapDay.detectedInfo?.meta.expirationDate.timeIntervalSince1970, 1_709_208_000)

        let lowercase = makeReader(expiration: "2026-10-11t12:00:00z")
        await lowercase.processQRCode(qrID)
        XCTAssertNil(lowercase.error)
        XCTAssertEqual(lowercase.detectedInfo?.meta.expirationDate.timeIntervalSince1970, 1_791_720_000)
    }
}

private final class ReaderFixtureTransport: NetworkTransport {
    private let id: String
    private let data: ReadQuery.Data

    init(id: String, data: ReadQuery.Data) {
        self.id = id
        self.data = data
    }

    func send<Query: GraphQLQuery>(query: Query, fetchBehavior: FetchBehavior, requestConfiguration: RequestConfiguration) throws -> AsyncThrowingStream<GraphQLResponse<Query>, Error> {
        guard let query = query as? ReadQuery, query.id == id else {
            throw URLError(.resourceUnavailable)
        }
        guard let response = data as? Query.Data else { throw URLError(.unsupportedURL) }
        return AsyncThrowingStream { continuation in
            continuation.yield(GraphQLResponse(data: response, extensions: nil, errors: nil, source: .server, dependentKeys: nil))
            continuation.finish()
        }
    }

    func send<Mutation: GraphQLMutation>(mutation: Mutation, requestConfiguration: RequestConfiguration) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, Error> {
        throw URLError(.unsupportedURL)
    }
}

@MainActor
private final class RetainingInfoReader: TeaElephant.ShortInfoReader {
    var callback: (@MainActor (TeaElephant.TeaMeta) async -> Void)?
    var errorCallback: (@MainActor (Error) -> Void)?

    @MainActor
    func startReadInfo() {}

    func setOnRead(_ onRead: @escaping @MainActor (TeaElephant.TeaMeta) async -> Void) {
        callback = onRead
    }

    func setOnError(_ onError: @escaping @MainActor (Error) -> Void) {
        errorCallback = onError
    }
}

@MainActor
private final class DeferredExtender: TeaElephant.ExtendInfoReader {
    private let onStart: () -> Void
    private var continuation: CheckedContinuation<TeaData, Error>?

    init(onStart: @escaping () -> Void) {
        self.onStart = onStart
    }

    func getExtendInfo(id: String) async throws -> TeaData {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            onStart()
        }
    }

    func fail() {
        continuation?.resume(throwing: URLError(.cannotParseResponse))
        continuation = nil
    }
}

private final class ControlledReaderTransport: NetworkTransport, @unchecked Sendable {
    private let lock = NSLock()
    private var pending: [String: @Sendable (ReadQuery.Data) -> Void] = [:]
    private let onSend: @Sendable (String) -> Void

    init(onSend: @escaping @Sendable (String) -> Void) {
        self.onSend = onSend
    }

    func complete(id: String, data: ReadQuery.Data) {
        let callback = lock.withLock { pending.removeValue(forKey: id) }
        callback?(data)
    }

    func send<Query: GraphQLQuery>(query: Query, fetchBehavior: FetchBehavior, requestConfiguration: RequestConfiguration) throws -> AsyncThrowingStream<GraphQLResponse<Query>, Error> {
        guard let read = query as? ReadQuery else { throw URLError(.unsupportedURL) }
        return AsyncThrowingStream { continuation in
            lock.withLock {
                pending[read.id] = { data in
                    guard let response = data as? Query.Data else {
                        continuation.finish(throwing: URLError(.cannotParseResponse))
                        return
                    }
                    continuation.yield(GraphQLResponse(data: response, extensions: nil, errors: nil, source: .server, dependentKeys: nil))
                    continuation.finish()
                }
            }
            onSend(read.id)
        }
    }

    func send<Mutation: GraphQLMutation>(mutation: Mutation, requestConfiguration: RequestConfiguration) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, Error> {
        throw URLError(.unsupportedURL)
    }
}
