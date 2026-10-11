import XCTest
@preconcurrency import CoreNFC
import TeaElephantSchema
@testable import TeaElephant

final class SaveRegressionTests: XCTestCase {
    @MainActor
    func testUnsupportedNFCWriteThrowsInsteadOfReportingSuccess() async throws {
        guard !NFCTagReaderSession.readingAvailable else {
            throw XCTSkip("This regression requires a device without NFC writing support.")
        }

        do {
            try await TeaElephant.tagWriter().writeData(info: metadata())
            XCTFail("Unavailable NFC must fail instead of reporting a successful write.")
        } catch {
            XCTAssertEqual(error as? TeaElephant.NFCWriteError, .unavailable)
        }
    }

    @MainActor
    func testNFCWriteWaitsForActualWriteCompletion() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let writer = nfcWriter(session)
        let attempt = await beginWrite(writer, session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        XCTAssertNil(attempt.observation.result)
        session.detect([tag])
        XCTAssertNil(attempt.observation.result)
        tag.completeConnection()
        XCTAssertNil(attempt.observation.result)
        tag.completeStatus(.readWrite, capacity: 1_024)
        XCTAssertNil(attempt.observation.result)
        XCTAssertFalse(session.isInvalidated)

        tag.completeWrite()
        assertSuccess(await completedResult(attempt))
        XCTAssertTrue(session.isInvalidated)
    }

    @MainActor
    func testSuccessfulNFCWriteSendsRequestedMetadata() async throws {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection()
        tag.completeStatus(.readWrite, capacity: 1_024)

        let message = try XCTUnwrap(tag.writtenMessage)
        XCTAssertEqual(message.records.count, 1)
        let record = try XCTUnwrap(message.records.first)
        let written = try TeaElephant.TeaMeta.fromBytes(data: record.payload)
        XCTAssertEqual(written.id, "d25b2e4f-e39c-4ab3-98e5-ed317587796a")
        XCTAssertEqual(written.expirationDate.timeIntervalSince1970, 1_800_000_000)
        XCTAssertEqual(written.brewingTemp, 85)

        tag.completeWrite()
        assertSuccess(await completedResult(attempt))
    }

    @MainActor
    func testNFCWritePropagatesConnectionFailure() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection(error: NSError(domain: "ConnectProbe", code: 31))

        assertHardwareError(await completedResult(attempt), domain: "ConnectProbe", code: 31)
        XCTAssertTrue(session.isInvalidated)
        XCTAssertNil(tag.writtenMessage)
    }

    @MainActor
    func testNFCWritePropagatesStatusFailure() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection()
        tag.completeStatus(.readWrite, capacity: 1_024, error: NSError(domain: "StatusProbe", code: 32))

        assertHardwareError(await completedResult(attempt), domain: "StatusProbe", code: 32)
        XCTAssertTrue(session.isInvalidated)
        XCTAssertNil(tag.writtenMessage)
    }

    @MainActor
    func testNFCWriteRejectsReadOnlyTag() async {
        await assertRejectedStatus(.readOnly, expected: .readOnly)
    }

    @MainActor
    func testNFCWriteRejectsUnsupportedTag() async {
        await assertRejectedStatus(.notSupported, expected: .notSupported)
    }

    @MainActor
    func testNFCWriteRejectsInsufficientCapacity() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection()
        tag.completeStatus(.readWrite, capacity: 1)

        assertNFCError(await completedResult(attempt), expected: .insufficientCapacity)
        XCTAssertTrue(session.isInvalidated)
        XCTAssertNil(tag.writtenMessage)
    }

    @MainActor
    func testNFCWritePropagatesWriteFailure() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection()
        tag.completeStatus(.readWrite, capacity: 1_024)
        tag.completeWrite(error: NSError(domain: "WriteProbe", code: 33))

        assertHardwareError(await completedResult(attempt), domain: "WriteProbe", code: 33)
        XCTAssertTrue(session.isInvalidated)
    }

    @MainActor
    func testNFCSessionCancellationFailsPendingWrite() async {
        let session = WriteSessionFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.fail(NSError(domain: "SessionCancellationProbe", code: 200))

        assertHardwareError(await completedResult(attempt), domain: "SessionCancellationProbe", code: 200)
        XCTAssertTrue(session.isInvalidated)
    }

    @MainActor
    func testNFCTaskCancellationFailsPendingWrite() async {
        let session = WriteSessionFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        attempt.task.cancel()
        let error = failure(await completedResult(attempt))

        XCTAssertTrue(error is CancellationError)
        XCTAssertTrue(session.isInvalidated)
    }

    @MainActor
    func testNFCCancellationWinsOverImmediateWriteCompletion() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection()
        tag.completeStatus(.readWrite, capacity: 1_024)
        attempt.task.cancel()
        tag.completeWrite()

        let error = failure(await completedResult(attempt))
        XCTAssertTrue(error is CancellationError)
        XCTAssertTrue(session.isInvalidated)
    }

    @MainActor
    func testNFCCancellationPreventsLateStatusFromStartingWrite() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection()
        attempt.task.cancel()
        tag.completeStatus(.readWrite, capacity: 1_024)

        XCTAssertNil(tag.writtenMessage, "A cancelled operation must not start writing the tag.")
        let error = failure(await completedResult(attempt))
        XCTAssertTrue(error is CancellationError)
    }

    @MainActor
    func testNFCWriterRejectsConcurrentWriteWithoutCancellingFirstWrite() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let writer = nfcWriter(session)
        let first = await beginWrite(writer, session: session)
        let second = observeWrite(writer)
        defer { first.task.cancel(); second.task.cancel(); session.invalidate() }

        assertNFCError(await completedResult(second), expected: .writeInProgress)
        XCTAssertNil(first.observation.result)
        XCTAssertFalse(session.isInvalidated)

        session.detect([tag])
        tag.completeConnection()
        tag.completeStatus(.readWrite, capacity: 1_024)
        tag.completeWrite()
        assertSuccess(await completedResult(first))
    }

    @MainActor
    func testNFCWriterIgnoresRepeatedCallbacksFromEarlierStages() async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session)
        defer { attempt.task.cancel(); session.invalidate() }

        session.detect([tag])
        tag.completeConnection()
        tag.completeConnection(error: NSError(domain: "DuplicateConnectProbe", code: 34))
        tag.completeStatus(.readWrite, capacity: 1_024)
        tag.completeStatus(.readOnly, capacity: 1_024)
        XCTAssertNil(attempt.observation.result)

        tag.completeWrite()
        tag.completeWrite(error: NSError(domain: "DuplicateWriteProbe", code: 35))
        tag.completeWrite()
        assertSuccess(await completedResult(attempt))
    }

    @MainActor
    func testNFCWriterIgnoresStaleSessionCallbacksDuringNextWrite() async {
        let firstSession = WriteSessionFake()
        let secondSession = WriteSessionFake()
        var sessions = [firstSession, secondSession]
        let writer = TeaElephant.tagWriter(isAvailable: { true }, sessionFactory: { sessions.removeFirst() })
        let first = await beginWrite(writer, session: firstSession)
        let oldInvalidation = firstSession.onInvalidate
        let oldDetection = firstSession.onDetectTags
        firstSession.fail(NSError(domain: "OldSessionProbe", code: 36))
        _ = failure(await completedResult(first))

        let second = await beginWrite(writer, session: secondSession)
        defer { first.task.cancel(); second.task.cancel(); secondSession.invalidate() }
        oldInvalidation?(NSError(domain: "StaleSessionProbe", code: 37))
        oldDetection?([WriteTagFake()])
        XCTAssertNil(second.observation.result)
        XCTAssertFalse(secondSession.isInvalidated)

        let tag = WriteTagFake()
        secondSession.detect([tag])
        tag.completeConnection()
        tag.completeStatus(.readWrite, capacity: 1_024)
        tag.completeWrite()
        assertSuccess(await completedResult(second))
    }

    @MainActor
    func testNFCWriterIgnoresOldWriteCompletionAfterCancellation() async {
        let firstSession = WriteSessionFake()
        let secondSession = WriteSessionFake()
        var sessions = [firstSession, secondSession]
        let writer = TeaElephant.tagWriter(isAvailable: { true }, sessionFactory: { sessions.removeFirst() })
        let first = await beginWrite(writer, session: firstSession)
        let firstTag = WriteTagFake()
        firstSession.detect([firstTag])
        firstTag.completeConnection()
        firstTag.completeStatus(.readWrite, capacity: 1_024)
        first.task.cancel()
        let cancellation = failure(await completedResult(first))
        XCTAssertTrue(cancellation is CancellationError)

        let second = await beginWrite(writer, session: secondSession)
        defer { first.task.cancel(); second.task.cancel(); secondSession.invalidate() }
        firstTag.completeWrite()
        XCTAssertNil(second.observation.result)
        XCTAssertFalse(secondSession.isInvalidated)

        let secondTag = WriteTagFake()
        secondSession.detect([secondTag])
        secondTag.completeConnection()
        secondTag.completeStatus(.readWrite, capacity: 1_024)
        secondTag.completeWrite()
        assertSuccess(await completedResult(second))
    }

    @MainActor
    func testUnselectedSearchSuggestionCreatesNewTea() throws {
        let searcher = TeaElephant.Searcher(NoSearch())
        searcher.detectedInfo = suggestedTea(id: "suggested-tea")
        let selection = TeaElephant.TeaSaveSelection()

        guard case .new(let data) = try selection.target(name: "My own tea", type: .herb, description: "My own description") else {
            return XCTFail("A search suggestion must not choose an existing tea.")
        }
        XCTAssertEqual(data.name, "My own tea")
        XCTAssertEqual(data.type.value, .herb)
        XCTAssertEqual(data.description, "My own description")
    }

    @MainActor
    func testExplicitSelectionSurvivesBackgroundSearchChange() throws {
        let searcher = TeaElephant.Searcher(NoSearch())
        searcher.detectedInfo = suggestedTea(id: "chosen-tea")
        var selection = TeaElephant.TeaSaveSelection()
        selection.select(id: try XCTUnwrap(searcher.detectedInfo).meta.id)
        searcher.detectedInfo = suggestedTea(id: "later-suggestion")

        guard case .existing(let id) = try selection.target(name: "Chosen tea", type: .tea, description: "") else {
            return XCTFail("The explicit selection must choose the existing tea.")
        }
        XCTAssertEqual(id, "chosen-tea")
    }

    @MainActor
    func testResetRemovesExistingTeaFromNextSave() throws {
        var selection = TeaElephant.TeaSaveSelection()
        selection.select(id: "previous-tea")
        selection.reset()

        guard case .new(let data) = try selection.target(name: "Next tea", type: .tea, description: "") else {
            return XCTFail("A reset form must create its new tea instead of reusing the previous ID.")
        }
        XCTAssertEqual(data.name, "Next tea")
    }

    @MainActor
    func testWhitespaceOnlyNameCannotCreateTea() {
        let selection = TeaElephant.TeaSaveSelection()
        for name in ["", "   ", "\t\n  "] {
            XCTAssertThrowsError(try selection.target(name: name, type: .tea, description: ""), "Rejected input: \(name.debugDescription)")
        }
    }

    @MainActor
    func testNameLengthUsesTrimmedName() {
        let selection = TeaElephant.TeaSaveSelection()
        XCTAssertThrowsError(try selection.target(name: " \tA\n ", type: .tea, description: ""))
        XCTAssertThrowsError(try selection.target(name: String(repeating: "A", count: 101), type: .tea, description: ""))
    }

    @MainActor
    func testNewTeaIsSavedWithNormalizedName() throws {
        let selection = TeaElephant.TeaSaveSelection()
        guard case .new(let data) = try selection.target(name: " \tDragon Well\n ", type: .tea, description: "") else {
            return XCTFail("Expected a new tea.")
        }
        XCTAssertEqual(data.name, "Dragon Well")
    }

    @MainActor
    func testPaddedMaximumLengthNameRemainsValid() throws {
        let name = String(repeating: "A", count: 100)
        let selection = TeaElephant.TeaSaveSelection()
        guard case .new(let data) = try selection.target(name: "  \(name) \n", type: .tea, description: "") else {
            return XCTFail("Expected a new tea.")
        }
        XCTAssertEqual(data.name, name)
        XCTAssertEqual(data.name.count, 100)
    }

    @MainActor
    private func metadata() -> TeaElephant.TeaMeta {
        TeaElephant.TeaMeta(id: "d25b2e4f-e39c-4ab3-98e5-ed317587796a", expirationDate: Date(timeIntervalSince1970: 1_800_000_000), brewingTemp: 85)
    }

    @MainActor
    private func nfcWriter(_ session: WriteSessionFake) -> TeaElephant.tagWriter {
        TeaElephant.tagWriter(isAvailable: { true }, sessionFactory: { session })
    }

    @MainActor
    private func observeWrite(_ writer: TeaElephant.tagWriter) -> WriteAttempt {
        let observation = WriteObservation()
        let meta = metadata()
        let task = Task { @MainActor in
            do {
                try await writer.writeData(info: meta)
                observation.result = .success(())
            } catch {
                observation.result = .failure(error)
            }
            observation.finished.fulfill()
        }
        return WriteAttempt(task: task, observation: observation)
    }

    @MainActor
    private func beginWrite(_ writer: TeaElephant.tagWriter, session: WriteSessionFake, file: StaticString = #filePath, line: UInt = #line) async -> WriteAttempt {
        let attempt = observeWrite(writer)
        let started = await XCTWaiter.fulfillment(of: [session.began], timeout: 2)
        XCTAssertEqual(started, .completed, "The writer must start the NFC session.", file: file, line: line)
        return attempt
    }

    @MainActor
    private func completedResult(_ attempt: WriteAttempt, file: StaticString = #filePath, line: UInt = #line) async -> Result<Void, Error>? {
        let finished = await XCTWaiter.fulfillment(of: [attempt.observation.finished], timeout: 2)
        XCTAssertEqual(finished, .completed, "The NFC operation must finish.", file: file, line: line)
        return attempt.observation.result
    }

    @MainActor
    private func failure(_ result: Result<Void, Error>?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        guard case .failure(let error)? = result else {
            XCTFail("Expected NFC writing to fail.", file: file, line: line)
            return nil
        }
        return error
    }

    @MainActor
    private func assertSuccess(_ result: Result<Void, Error>?, file: StaticString = #filePath, line: UInt = #line) {
        guard case .success? = result else {
            return XCTFail("Expected a confirmed successful NFC write.", file: file, line: line)
        }
    }

    @MainActor
    private func assertNFCError(_ result: Result<Void, Error>?, expected: TeaElephant.NFCWriteError, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(failure(result, file: file, line: line) as? TeaElephant.NFCWriteError, expected, file: file, line: line)
    }

    @MainActor
    private func assertHardwareError(_ result: Result<Void, Error>?, domain: String, code: Int, file: StaticString = #filePath, line: UInt = #line) {
        guard let capturedError = failure(result, file: file, line: line) else { return }
        let error = capturedError as NSError
        XCTAssertEqual(error.domain, domain, file: file, line: line)
        XCTAssertEqual(error.code, code, file: file, line: line)
    }

    @MainActor
    private func assertRejectedStatus(_ status: NFCNDEFStatus, expected: TeaElephant.NFCWriteError, file: StaticString = #filePath, line: UInt = #line) async {
        let session = WriteSessionFake()
        let tag = WriteTagFake()
        let attempt = await beginWrite(nfcWriter(session), session: session, file: file, line: line)
        defer { attempt.task.cancel(); session.invalidate() }
        session.detect([tag])
        tag.completeConnection()
        tag.completeStatus(status, capacity: 1_024)

        assertNFCError(await completedResult(attempt, file: file, line: line), expected: expected, file: file, line: line)
        XCTAssertTrue(session.isInvalidated, file: file, line: line)
        XCTAssertNil(tag.writtenMessage, file: file, line: line)
    }

    @MainActor
    private func suggestedTea(id: String) -> TeaElephant.TeaInfo {
        TeaElephant.TeaInfo(meta: TeaElephant.TeaMeta(id: id, expirationDate: Date(timeIntervalSince1970: 1_800_000_000), brewingTemp: 85), data: TeaData(name: "Suggested tea", type: GraphQLEnum(.tea), description: "Suggested description"), tags: [])
    }
}

@MainActor
private struct WriteAttempt {
    let task: Task<Void, Never>
    let observation: WriteObservation
}

@MainActor
private final class WriteObservation {
    var result: Result<Void, Error>?
    let finished = XCTestExpectation(description: "NFC writing finished")
}

@MainActor
private final class WriteSessionFake: TeaElephant.NFCWriteSession {
    var onDetectTags: (@MainActor ([any TeaElephant.NFCWriteTag]) -> Void)?
    var onInvalidate: (@MainActor (Error) -> Void)?
    var alertMessage = ""
    var isInvalidated = false
    let began = XCTestExpectation(description: "NFC writing began")

    func begin() { began.fulfill() }
    func restartPolling() {}

    func invalidate() {
        isInvalidated = true
        onInvalidate?(URLError(.cancelled))
    }

    func detect(_ tags: [any TeaElephant.NFCWriteTag]) { onDetectTags?(tags) }
    func fail(_ error: Error) { onInvalidate?(error) }
}

@MainActor
private final class WriteTagFake: TeaElephant.NFCWriteTag {
    private var connectionCompletion: (@MainActor @Sendable (Error?) -> Void)?
    private var statusCompletion: (@MainActor @Sendable (NFCNDEFStatus, Int, Error?) -> Void)?
    private var writeCompletion: (@MainActor @Sendable (Error?) -> Void)?
    var writtenMessage: NFCNDEFMessage?

    func connect(completion: @escaping @MainActor @Sendable (Error?) -> Void) { connectionCompletion = completion }
    func queryNDEFStatus(completion: @escaping @MainActor @Sendable (NFCNDEFStatus, Int, Error?) -> Void) { statusCompletion = completion }
    func writeNDEF(_ message: NFCNDEFMessage, completion: @escaping @MainActor @Sendable (Error?) -> Void) {
        writtenMessage = message
        writeCompletion = completion
    }

    func completeConnection(error: Error? = nil) { connectionCompletion?(error) }
    func completeStatus(_ status: NFCNDEFStatus, capacity: Int, error: Error? = nil) { statusCompletion?(status, capacity, error) }
    func completeWrite(error: Error? = nil) { writeCompletion?(error) }
}

@MainActor
private final class NoSearch: TeaElephant.ApiSearcher {
    func search(prefix: String) async throws -> TeaElephant.TeaDataWithID? { nil }
}
