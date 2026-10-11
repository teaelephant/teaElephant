import Foundation
@preconcurrency import CoreNFC

@MainActor
protocol NFCWriteSession: AnyObject, Sendable {
    var onDetectTags: (@MainActor ([any NFCWriteTag]) -> Void)? { get set }
    var onInvalidate: (@MainActor (Error) -> Void)? { get set }
    var alertMessage: String { get set }
    func begin()
    func restartPolling()
    func invalidate()
}

@MainActor
protocol NFCWriteTag: AnyObject, Sendable {
    func connect(completion: @escaping @MainActor @Sendable (Error?) -> Void)
    func queryNDEFStatus(completion: @escaping @MainActor @Sendable (NFCNDEFStatus, Int, Error?) -> Void)
    func writeNDEF(_ message: NFCNDEFMessage, completion: @escaping @MainActor @Sendable (Error?) -> Void)
}

enum NFCWriteError: LocalizedError, Equatable {
    case unavailable
    case writeInProgress
    case notSupported
    case readOnly
    case insufficientCapacity
    case unknownStatus

    var errorDescription: String? {
        switch self {
        case .unavailable: return "NFC writing is not available on this device."
        case .writeInProgress: return "An NFC write is already in progress."
        case .notSupported: return "Tag is not NDEF compliant."
        case .readOnly: return "Tag is read only."
        case .insufficientCapacity: return "The NFC tag does not have enough capacity for this tea."
        case .unknownStatus: return "Unknown NDEF tag status."
        }
    }
}

@MainActor
final class tagWriter: ShortInfoWriter {
    private let isAvailable: () -> Bool
    private let sessionFactory: () -> any NFCWriteSession
    private var pending: PendingWrite?

    convenience init() {
        self.init(isAvailable: { NFCTagReaderSession.readingAvailable }, sessionFactory: { CoreNFCWriteSession() })
    }

    init(isAvailable: @escaping () -> Bool, sessionFactory: @escaping () -> any NFCWriteSession) {
        self.isAvailable = isAvailable
        self.sessionFactory = sessionFactory
    }

    func writeData(info: TeaMeta) async throws {
        guard pending == nil else { throw NFCWriteError.writeInProgress }
        try Task.checkCancellation()
        guard isAvailable() else { throw NFCWriteError.unavailable }

        let payload = NFCNDEFPayload(format: .nfcWellKnown, type: Data("application/json".utf8), identifier: Data(), payload: try info.toBytes())
        let message = NFCNDEFMessage(records: [payload])
        let operationID = UUID()
        let cancellation = NFCWriteCancellation()

        try await withTaskCancellationHandler {
            try Task.checkCancellation()
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                guard !Task.isCancelled else {
                    continuation.resume(throwing: CancellationError())
                    return
                }

                let session = sessionFactory()
                pending = PendingWrite(id: operationID, session: session, message: message, cancellation: cancellation, continuation: continuation)
                session.onInvalidate = { [weak self, weak session] error in
                    guard let self, let session, self.pending?.session === session else { return }
                    self.finish(operationID, result: .failure(error))
                }
                session.onDetectTags = { [weak self, weak session] tags in
                    guard let self, let session, self.pending?.session === session else { return }
                    self.detected(tags, operationID: operationID)
                }
                session.alertMessage = "Hold your iPhone near an NDEF tag to write the tea."
                session.begin()
            }
        } onCancel: { [weak self] in
            cancellation.cancel()
            Task { @MainActor [weak self] in
                self?.finish(operationID, result: .failure(CancellationError()))
            }
        }
    }

    private func detected(_ tags: [any NFCWriteTag], operationID: UUID) {
        guard let operation = active(operationID, stage: .detecting) else { return }
        guard tags.count == 1, let tag = tags.first else {
            operation.session.alertMessage = "Please hold only one NFC tag near your iPhone."
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 500_000_000)
                self?.active(operationID, stage: .detecting)?.session.restartPolling()
            }
            return
        }

        operation.stage = .connecting
        tag.connect { [weak self] error in
            guard let self, let operation = self.active(operationID, stage: .connecting) else { return }
            if let error {
                self.finish(operationID, result: .failure(error))
                return
            }
            operation.stage = .checkingStatus
            tag.queryNDEFStatus { [weak self] status, capacity, error in
                self?.receivedStatus(status, capacity: capacity, error: error, tag: tag, operationID: operationID)
            }
        }
    }

    private func receivedStatus(_ status: NFCNDEFStatus, capacity: Int, error: Error?, tag: any NFCWriteTag, operationID: UUID) {
        guard let operation = active(operationID, stage: .checkingStatus) else { return }
        if let error {
            finish(operationID, result: .failure(error))
            return
        }

        switch status {
        case .notSupported:
            finish(operationID, result: .failure(NFCWriteError.notSupported))
        case .readOnly:
            finish(operationID, result: .failure(NFCWriteError.readOnly))
        case .readWrite:
            guard operation.message.length <= capacity else {
                finish(operationID, result: .failure(NFCWriteError.insufficientCapacity))
                return
            }
            operation.stage = .writing
            tag.writeNDEF(operation.message) { [weak self] error in
                guard let self, self.active(operationID, stage: .writing) != nil else { return }
                if let error {
                    self.finish(operationID, result: .failure(error))
                } else {
                    self.finish(operationID, result: .success(()))
                }
            }
        @unknown default:
            finish(operationID, result: .failure(NFCWriteError.unknownStatus))
        }
    }

    private func active(_ operationID: UUID, stage: PendingWrite.Stage) -> PendingWrite? {
        guard let pending, pending.id == operationID, pending.stage == stage, !pending.cancellation.isCancelled else { return nil }
        return pending
    }

    private func finish(_ operationID: UUID, result: Result<Void, Error>) {
        guard let operation = pending, operation.id == operationID else { return }
        var completionResult = result
        if case .success = result, operation.cancellation.isCancelled {
            completionResult = .failure(CancellationError())
        }
        pending = nil
        operation.session.onDetectTags = nil
        operation.session.onInvalidate = nil
        switch completionResult {
        case .success:
            operation.session.alertMessage = "Write NDEF message successful."
        case .failure(let error):
            operation.session.alertMessage = error.localizedDescription
        }
        operation.session.invalidate()
        operation.continuation.resume(with: completionResult)
    }

    private final class PendingWrite {
        enum Stage {
            case detecting, connecting, checkingStatus, writing
        }

        let id: UUID
        let session: any NFCWriteSession
        let message: NFCNDEFMessage
        let cancellation: NFCWriteCancellation
        let continuation: CheckedContinuation<Void, Error>
        var stage = Stage.detecting

        init(id: UUID, session: any NFCWriteSession, message: NFCNDEFMessage, cancellation: NFCWriteCancellation, continuation: CheckedContinuation<Void, Error>) {
            self.id = id
            self.session = session
            self.message = message
            self.cancellation = cancellation
            self.continuation = continuation
        }
    }
}

private final class NFCWriteCancellation: @unchecked Sendable {
    private let lock = NSLock()
    private var cancelled = false

    var isCancelled: Bool { lock.withLock { cancelled } }

    func cancel() {
        lock.withLock { cancelled = true }
    }
}

@MainActor
private final class CoreNFCWriteSession: NSObject, NFCWriteSession {
    var onDetectTags: (@MainActor ([any NFCWriteTag]) -> Void)?
    var onInvalidate: (@MainActor (Error) -> Void)?
    private lazy var nfc = NearFieldCommunicator(delegate: self)
    var alertMessage = "" {
        didSet { nfc.session?.alertMessage = alertMessage }
    }

    func begin() {
        nfc.createSession(invalidateAfterFirstRead: false)
        guard let session = nfc.session else {
            onInvalidate?(NFCWriteError.unavailable)
            return
        }
        session.alertMessage = alertMessage
    }

    func restartPolling() { nfc.session?.restartPolling() }
    func invalidate() { nfc.invalidateSession() }
}

extension CoreNFCWriteSession: NFCProtocol {
    nonisolated func ready() {}
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let sessionBox = SendableBox(session)
        Task { @MainActor [weak self] in
            guard let self, self.nfc.session === sessionBox.value else { return }
            self.onInvalidate?(error)
        }
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        let sessionBox = SendableBox(session)
        let tagsBox = SendableBox(tags)
        Task { @MainActor [weak self] in
            guard let self, self.nfc.session === sessionBox.value else { return }
            self.onDetectTags?(tagsBox.value.map { CoreNFCWriteTag(session: sessionBox.value, tag: $0) })
        }
    }
}

@MainActor
private final class CoreNFCWriteTag: NFCWriteTag {
    private let session: NFCNDEFReaderSession
    private let tag: any NFCNDEFTag

    init(session: NFCNDEFReaderSession, tag: any NFCNDEFTag) {
        self.session = session
        self.tag = tag
    }

    func connect(completion: @escaping @MainActor @Sendable (Error?) -> Void) {
        session.connect(to: tag) { error in
            Task { @MainActor in completion(error) }
        }
    }

    func queryNDEFStatus(completion: @escaping @MainActor @Sendable (NFCNDEFStatus, Int, Error?) -> Void) {
        tag.queryNDEFStatus { status, capacity, error in
            let statusBox = SendableBox(status)
            Task { @MainActor in completion(statusBox.value, capacity, error) }
        }
    }

    func writeNDEF(_ message: NFCNDEFMessage, completion: @escaping @MainActor @Sendable (Error?) -> Void) {
        tag.writeNDEF(message) { error in
            Task { @MainActor in completion(error) }
        }
    }
}
