//
//  menager.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 18.07.2020.
//

import Foundation
import SwiftUI
@preconcurrency import CoreNFC

@MainActor
class NFCReader: NSObject, ObservableObject {
    lazy var nfc = NearFieldCommunicator(delegate: self)
    private var onRead: (@MainActor (_ meta: TeaMeta) async -> Void)?
    private var onError: (@MainActor (_ error: Error) -> Void)?
    @Published var detectedInfo: TeaMeta?
    @Published var error: Error?

    func setOnRead(_ onRead: @escaping @MainActor (_ meta: TeaMeta) async -> Void) {
        self.onRead = onRead
    }

    func setOnError(_ onError: @escaping @MainActor (_ error: Error) -> Void) {
        self.onError = onError
    }

    func startReadInfo() {
        detectedInfo = nil
        error = nil
        guard NFCTagReaderSession.readingAvailable else {
            fail(ReaderError.ScanningNotSupported)
            return
        }
        nfc.createSession()
    }

    private func didRead(_ meta: TeaMeta) async {
        detectedInfo = meta
        error = nil
        let callback = onRead
        clearCallbacks()
        nfc.invalidateSession()
        await callback?(meta)
    }

    private func fail(_ error: Error) {
        detectedInfo = nil
        self.error = error
        let callback = onError
        clearCallbacks()
        nfc.invalidateSession()
        callback?(error)
    }

    private func clearCallbacks() {
        onRead = nil
        onError = nil
    }
}

extension NFCReader: ShortInfoReader {}

extension NFCReader: NFCProtocol {
    nonisolated func ready() {}

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let sessionBox = SendableBox(session)
        Task { @MainActor [weak self] in
            guard let self, self.nfc.session === sessionBox.value else { return }
            // The detection callback owns the result and cleanup of a successful single read.
            // Its actor task may still be queued when CoreNFC reports automatic invalidation.
            if (error as? NFCReaderError)?.code == .readerSessionInvalidationErrorFirstNDEFTagRead {
                return
            }
            self.fail(error)
        }
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let payload: Result<Data, ReaderError>
        if messages.count != 1 {
            payload = .failure(.InvalidMessageCount)
        } else if messages[0].records.count != 1 {
            payload = .failure(.InvalidRecordsCount)
        } else {
            let record = messages[0].records[0]
            let supportedFormat = record.typeNameFormat == .nfcWellKnown || record.typeNameFormat == .media
            if supportedFormat && record.type == Data("application/json".utf8) {
                payload = .success(record.payload)
            } else {
                payload = .failure(.UnsupportedRecordType)
            }
        }

        let sessionBox = SendableBox(session)
        Task { @MainActor [weak self] in
            guard let self, self.nfc.session === sessionBox.value else { return }
            switch payload {
            case .failure(let error):
                self.fail(error)
            case .success(let data):
                do {
                    let meta = try TeaMeta.fromBytes(data: data)
                    await self.didRead(meta)
                } catch {
                    self.fail(error)
                }
            }
        }
    }
}

enum ReaderError: LocalizedError {
    case InvalidMessageCount
    case InvalidRecordsCount
    case UnsupportedRecordType
    case ScanningNotSupported

    var errorDescription: String? {
        switch self {
        case .InvalidMessageCount, .InvalidRecordsCount:
            return "This NFC tag does not contain a single tea record."
        case .UnsupportedRecordType:
            return "This NFC tag does not contain tea information."
        case .ScanningNotSupported:
            return "NFC scanning is not supported on this device."
        }
    }
}
