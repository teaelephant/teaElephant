import XCTest
import Combine
@preconcurrency import CoreNFC
@testable import TeaElephant

final class NFCReadRegressionTests: XCTestCase {
    private let teaID = "3c252497-9d87-44f0-b3de-2822c6b94df5"

    // A legacy tag contains three successive MessagePack values, without an array header.
    private var legacyPayload: Data {
        Data([0xd9, 0x24]) + Data(teaID.utf8)
            + Data([0xcb, 0, 0, 0, 0, 0, 0, 0, 0, 0x55])
    }

    func testLegacyTagStreamStillDecodes() throws {
        let meta = try TeaElephant.TeaMeta.fromBytes(data: legacyPayload)
        XCTAssertEqual(meta.id, teaID)
        XCTAssertEqual(meta.expirationDate.timeIntervalSince1970, 0)
        XCTAssertEqual(meta.brewingTemp, 85)
    }

    func testDecoderRejectsTrailingValues() {
        XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: legacyPayload + Data([0])))
    }

    func testDecoderRequiresDoubleMarkerForExpirationDate() {
        var payload = legacyPayload
        payload[38] = 0xc1
        XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: payload))
    }

    func testDecoderRejectsNonfiniteExpirationDates() {
        let nonfiniteDates: [[UInt8]] = [
            [0xcb, 0x7f, 0xf0, 0, 0, 0, 0, 0, 0], // Positive infinity.
            [0xcb, 0xff, 0xf0, 0, 0, 0, 0, 0, 0], // Negative infinity.
            [0xcb, 0x7f, 0xf8, 0, 0, 0, 0, 0, 0]  // NaN.
        ]
        for date in nonfiniteDates {
            let payload = Data([0xd9, 0x24]) + Data(teaID.utf8) + Data(date) + Data([0x55])
            XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: payload))
        }
    }

    func testDecoderAcceptsVariableWidthTemperatures() throws {
        let temperatures: [(bytes: [UInt8], expected: Int)] = [
            ([0xd0, 0x80], -128),
            ([0xd1, 0x00, 0xc8], 200),
            ([0xd2, 0x00, 0x01, 0x00, 0x00], 65_536),
            ([0xd3, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00], 4_294_967_296),
            ([0xcc, 0xc8], 200),
            ([0xcd, 0x01, 0x00], 256),
            ([0xce, 0x00, 0x01, 0x00, 0x00], 65_536),
            ([0xcf, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00], 4_294_967_296)
        ]
        for temperature in temperatures {
            let payload = Data(legacyPayload.dropLast()) + Data(temperature.bytes)
            let meta = try TeaElephant.TeaMeta.fromBytes(data: payload)
            XCTAssertEqual(meta.brewingTemp, temperature.expected)
            XCTAssertEqual(meta.id, teaID)
            XCTAssertEqual(meta.expirationDate.timeIntervalSince1970, 0)
        }
    }

    func testDecoderAcceptsString16ID() throws {
        let id = String(repeating: "x", count: 256)
        let payload = Data([0xda, 0x01, 0x00]) + Data(id.utf8)
            + Data([0xcb, 0, 0, 0, 0, 0, 0, 0, 0, 0x55])
        let meta = try TeaElephant.TeaMeta.fromBytes(data: payload)
        XCTAssertEqual(meta.id, id)
        XCTAssertEqual(meta.expirationDate.timeIntervalSince1970, 0)
        XCTAssertEqual(meta.brewingTemp, 85)
    }

    func testDecoderAcceptsFixStringIDAndFractionalDate() throws {
        let payload = Data([0xa3, 0x74, 0x65, 0x61, 0xcb, 0x3f, 0xe0, 0, 0, 0, 0, 0, 0, 0x55])
        let meta = try TeaElephant.TeaMeta.fromBytes(data: payload)
        XCTAssertEqual(meta.id, "tea")
        XCTAssertEqual(meta.expirationDate.timeIntervalSince1970, 0.5)
        XCTAssertEqual(meta.brewingTemp, 85)
    }

    func testDecoderAcceptsUnicodeID() throws {
        let payload = Data([0xa6, 0xd1, 0x87, 0xd0, 0xb0, 0xd0, 0xb9, 0xcb, 0, 0, 0, 0, 0, 0, 0, 0, 0x55])
        let meta = try TeaElephant.TeaMeta.fromBytes(data: payload)
        XCTAssertEqual(meta.id, "чай")
        XCTAssertEqual(meta.brewingTemp, 85)
    }

    func testDecoderAcceptsString32ID() throws {
        let id = String(repeating: "x", count: 65_536)
        let payload = Data([0xdb, 0x00, 0x01, 0x00, 0x00]) + Data(id.utf8)
            + Data([0xcb, 0, 0, 0, 0, 0, 0, 0, 0, 0x55])
        let meta = try TeaElephant.TeaMeta.fromBytes(data: payload)
        XCTAssertEqual(meta.id, id)
        XCTAssertEqual(meta.brewingTemp, 85)
    }

    func testDecoderRejectsEmptyOrInvalidUTF8ID() {
        let suffix = Data([0xcb, 0, 0, 0, 0, 0, 0, 0, 0, 0x55])
        XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: Data([0xa0]) + suffix))
        XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: Data([0xa1, 0xff]) + suffix))
    }

    func testDecoderRejectsTruncatedStringLengthHeaders() {
        let invalidHeaders: [[UInt8]] = [
            [], [0xd9], [0xda, 0x01], [0xdb, 0, 0, 1],
            [0xda, 0xff, 0xff], [0xdb, 0xff, 0xff, 0xff, 0xff]
        ]
        for header in invalidHeaders {
            XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: Data(header)))
        }
    }

    func testDecoderRejectsUnsignedTemperatureOverflow() {
        let payload = Data(legacyPayload.dropLast()) + Data([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: payload))
    }

    func testDecoderRejectsNonintegerTemperature() {
        let markers: [UInt8] = [0xc0, 0xc1, 0xc3, 0xcb]
        for marker in markers {
            let payload = Data(legacyPayload.dropLast()) + Data([marker])
            XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: payload))
        }
    }

    func testDecoderAcceptsDataWithNonzeroStartIndex() throws {
        let container = Data([0]) + legacyPayload
        let meta = try TeaElephant.TeaMeta.fromBytes(data: container.dropFirst())
        XCTAssertEqual(meta.id, teaID)
        XCTAssertEqual(meta.brewingTemp, 85)
    }

    @MainActor
    func testNFCReaderDoesNotRetainItsCommunicatorDelegate() {
        var reader: TeaElephant.NFCReader? = TeaElephant.NFCReader()
        let communicator = reader?.nfc
        weak let released = reader
        reader = nil
        XCTAssertNil(released, "Closing the reader must release the NFC delegate")
        XCTAssertNil(communicator?.delegate)
    }

    @MainActor
    func testForeignNDEFRecordIsRejectedBeforeReadingTea() async {
        let reader = TeaElephant.NFCReader()
        let session = attachSession(to: reader)
        let read = expectation(description: "Foreign NDEF record must not deliver tea")
        read.isInverted = true
        reader.setOnRead { _ in read.fulfill() }
        let record = NFCNDEFPayload(format: .nfcWellKnown, type: Data("T".utf8), identifier: Data(), payload: legacyPayload)

        reader.readerSession(session, didDetectNDEFs: [NFCNDEFMessage(records: [record])])
        await fulfillment(of: [read], timeout: 0.2)

        XCTAssertNil(reader.detectedInfo)
        XCTAssertNotNil(reader.error)
    }

    @MainActor
    func testPayloadParseFailureIsPublishedAndClearsPreviousTea() async {
        let reader = TeaElephant.NFCReader()
        let session = attachSession(to: reader)
        reader.detectedInfo = TeaElephant.TeaMeta(id: "previous-tea", expirationDate: Date(timeIntervalSince1970: 0), brewingTemp: 85)
        let receivedError = expectation(description: "NFC parse failure must be visible")
        let deliveredError = expectation(description: "NFC parse failure must reach the form callback")
        reader.setOnError { _ in deliveredError.fulfill() }
        let observation = reader.$error.compactMap { $0 }.sink { _ in receivedError.fulfill() }
        var corrupt = legacyPayload
        corrupt[0] = 0xc1
        let record = NFCNDEFPayload(format: .nfcWellKnown, type: Data("application/json".utf8), identifier: Data(), payload: corrupt)

        reader.readerSession(session, didDetectNDEFs: [NFCNDEFMessage(records: [record])])
        await fulfillment(of: [receivedError, deliveredError], timeout: 1)

        XCTAssertNil(reader.detectedInfo)
        XCTAssertNotNil(reader.error)
        withExtendedLifetime(observation) {}
    }

    @MainActor
    func testSuccessfulNFCReadClearsPreviousError() async {
        let reader = TeaElephant.NFCReader()
        let session = attachSession(to: reader)
        reader.error = NSError(domain: "NFCReadRegressionTests", code: 1)
        let read = expectation(description: "Valid legacy NFC payload is delivered")
        reader.setOnRead { meta in
            XCTAssertEqual(meta.id, "3c252497-9d87-44f0-b3de-2822c6b94df5")
            XCTAssertEqual(meta.brewingTemp, 85)
            read.fulfill()
        }
        let record = NFCNDEFPayload(format: .nfcWellKnown, type: Data("application/json".utf8), identifier: Data(), payload: legacyPayload)

        reader.readerSession(session, didDetectNDEFs: [NFCNDEFMessage(records: [record])])
        await fulfillment(of: [read], timeout: 1)

        XCTAssertNotNil(reader.detectedInfo)
        XCTAssertNil(reader.error)
    }

    @MainActor
    func testInvalidatedNFCSessionDoesNotStartAnotherScan() async {
        let reader = TeaElephant.NFCReader()
        let restarted = expectation(description: "Invalidation must not restart scanning")
        restarted.isInverted = true
        let communicator = SessionCreationProbe(delegate: reader, onCreate: { restarted.fulfill() })
        reader.nfc = communicator
        let session = attachSession(to: reader)
        let deliveredError = expectation(description: "Cancellation must reach the form callback")
        reader.setOnError { error in
            XCTAssertEqual((error as? NFCReaderError)?.code, .readerSessionInvalidationErrorUserCanceled)
            deliveredError.fulfill()
        }
        let cancellation = NSError(domain: NFCReaderError.errorDomain, code: NFCReaderError.Code.readerSessionInvalidationErrorUserCanceled.rawValue)

        reader.readerSession(session, didInvalidateWithError: cancellation)
        await fulfillment(of: [restarted, deliveredError], timeout: 0.2)

        XCTAssertNil(communicator.session)
    }

    @MainActor
    func testUnsupportedScanDeliversErrorToForm() throws {
        guard !NFCTagReaderSession.readingAvailable else {
            throw XCTSkip("This test needs a device without NFC")
        }
        let reader = TeaElephant.NFCReader()
        var deliveredError: Error?
        reader.setOnError { deliveredError = $0 }
        reader.startReadInfo()
        XCTAssertNotNil(deliveredError)
        XCTAssertNotNil(reader.error)
        XCTAssertNil(reader.nfc.session)
    }

    @MainActor
    func testFailureReleasesPendingReadCallback() async {
        let reader = TeaElephant.NFCReader()
        let session = attachSession(to: reader)
        var resource: NSObject? = NSObject()
        weak let releasedResource = resource
        reader.setOnRead { [resource] _ in XCTAssertNotNil(resource) }
        resource = nil
        let deliveredError = expectation(description: "Failure completes the read operation")
        reader.setOnError { _ in deliveredError.fulfill() }
        let record = NFCNDEFPayload(format: .nfcWellKnown, type: Data("T".utf8), identifier: Data(), payload: legacyPayload)

        reader.readerSession(session, didDetectNDEFs: [NFCNDEFMessage(records: [record])])
        await fulfillment(of: [deliveredError], timeout: 1)

        XCTAssertNil(releasedResource)
        XCTAssertNil(reader.nfc.session)
    }

    @MainActor
    func testOldSessionCannotInvalidateCurrentRead() async {
        let reader = TeaElephant.NFCReader()
        let oldSession = attachSession(to: reader)
        let currentSession = attachSession(to: reader)
        let deliveredError = expectation(description: "Old session must not fail the current read")
        deliveredError.isInverted = true
        reader.setOnError { _ in deliveredError.fulfill() }
        let cancellation = NSError(domain: NFCReaderError.errorDomain, code: NFCReaderError.Code.readerSessionInvalidationErrorUserCanceled.rawValue)

        reader.readerSession(oldSession, didInvalidateWithError: cancellation)
        await fulfillment(of: [deliveredError], timeout: 0.2)

        XCTAssertTrue(reader.nfc.session === currentSession)
        XCTAssertNil(reader.error)
    }

    @MainActor
    func testAutomaticInvalidationDoesNotDiscardDetectedTea() async {
        let reader = TeaElephant.NFCReader()
        let session = attachSession(to: reader)
        let read = expectation(description: "Automatic invalidation must preserve the detected tea")
        reader.setOnRead { _ in read.fulfill() }
        let completed = NSError(domain: NFCReaderError.errorDomain, code: NFCReaderError.Code.readerSessionInvalidationErrorFirstNDEFTagRead.rawValue)
        let record = NFCNDEFPayload(format: .nfcWellKnown, type: Data("application/json".utf8), identifier: Data(), payload: legacyPayload)

        reader.readerSession(session, didInvalidateWithError: completed)
        reader.readerSession(session, didDetectNDEFs: [NFCNDEFMessage(records: [record])])
        await fulfillment(of: [read], timeout: 1)

        XCTAssertEqual(reader.detectedInfo?.id, teaID)
        XCTAssertNil(reader.error)
        XCTAssertNil(reader.nfc.session)
    }

    @MainActor
    private func attachSession(to reader: TeaElephant.NFCReader) -> NFCNDEFReaderSession {
        let session = NFCNDEFReaderSession(delegate: reader, queue: nil, invalidateAfterFirstRead: true)
        reader.nfc.session = session
        return session
    }
}

// Keep the pre-fix trap isolated so it can be run separately during the red phase.
final class NFCShortPayloadRegressionTests: XCTestCase {
    func testShortNFCPayloadThrowsInsteadOfCrashing() {
        XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: Data([0xa1, 0x78])))
    }

    func testEveryTruncatedPayloadThrows() {
        let payload = Data([0xd9, 0x24]) + Data("3c252497-9d87-44f0-b3de-2822c6b94df5".utf8)
            + Data([0xcb, 0, 0, 0, 0, 0, 0, 0, 0])
            + Data([0xd3, 0, 0, 0, 0, 0, 0, 0, 0x55])
        for count in 0..<payload.count {
            XCTAssertThrowsError(try TeaElephant.TeaMeta.fromBytes(data: Data(payload.prefix(count))))
        }
    }
}

@MainActor
private final class SessionCreationProbe: TeaElephant.NearFieldCommunicator {
    private let onCreate: () -> Void

    init(delegate: TeaElephant.NFCProtocol, onCreate: @escaping () -> Void) {
        self.onCreate = onCreate
        super.init(delegate: delegate)
    }

    override func createSession(invalidateAfterFirstRead: Bool = true) {
        onCreate()
    }
}
