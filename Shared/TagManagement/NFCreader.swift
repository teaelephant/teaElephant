//
//  menager.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 18.07.2020.
//

import Foundation
import SwiftUI
import UIKit
@preconcurrency import CoreNFC
import MessagePacker

@MainActor
class NFCReader: NSObject, ObservableObject {
    var nfc: NearFieldCommunicator!
    nonisolated(unsafe) private var onRead: ((_ meta: TeaMeta) async -> Void)?
    @Published var detectedInfo: TeaMeta?
    @Published var error: Error?

    override init() {
        super.init()
        nfc = NearFieldCommunicator(delegate: self)
    }
    
    nonisolated func setOnRead(_ onRead: @escaping (_ meta: TeaMeta) async -> Void) {
        self.onRead = onRead
    }

    func startReadInfo() {
        guard NFCTagReaderSession.readingAvailable else {
            print("Scanning Not Supported")
            return
        }
        self.nfc.createSession()
        /*session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        self.session?.alertMessage = "Приложи телефон к баночке с чаем чтобы узнать что в ней"
        self.session?.begin()
        print("start")*/
    }
}

@MainActor extension NFCReader: ShortInfoReader {
    // startReadInfo is @MainActor
    // setOnRead is not @MainActor
}

extension NFCReader: NFCProtocol {

    nonisolated func ready() -> Void {
    }

    /*!
     * @method readerSession:didInvalidateWithError:
     *
     * @param session   The session object that is invalidated.
     * @param error     The error indicates the invalidation reason.
     *
     * @discussion      Gets called when a session becomes invalid.  At this point the client is expected to discard
     *                  the returned session object.
     */
    nonisolated public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                       && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let errorToSet = error
                Task { @MainActor in
                    MainActor.assertIsolated()
                    self.error = errorToSet
                }
            }
        }

        // To read new tags, a new session instance is required.
        Task { @MainActor in
            MainActor.assertIsolated()
            self.nfc.createSession()
        }
    }

    /*!
     * @method readerSession:didDetectNDEFs:
     *
     * @param session   The session object used for tag detection.
     * @param messages  Array of @link NFCNDEFMessage @link/ objects. The order of the discovery on the tag is maintained.
     *
     * @discussion      Gets called when the reader detects NFC tag(s) with NDEF messages in the polling sequence.  Polling
     *                  is automatically restarted once the detected tag is removed from the reader's read range.
     */
    nonisolated public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("\(messages)")
        // Extract data before Task to avoid capturing non-Sendable values
        guard messages.count == 1 else {
            Task { @MainActor in
                MainActor.assertIsolated()
                self.error = ReaderError.InvalidMessageCount
                if let error = self.error {
                    print(error.localizedDescription)
                }
            }
            return
        }
        
        guard messages[0].records.count == 1 else {
            Task { @MainActor in
                MainActor.assertIsolated()
                self.error = ReaderError.InvalidRecordsCount
                if let error = self.error {
                    print(error.localizedDescription)
                }
            }
            return
        }
        
        let payload = messages[0].records[0].payload
        Task { @MainActor in
            MainActor.assertIsolated()
            do {
                self.detectedInfo = try TeaMeta.fromBytes(data: payload)
                if let onRead = self.onRead, let detectedInfo = self.detectedInfo {
                    await onRead(detectedInfo)
                }
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
}

enum ReaderError: Error {
    case InvalidMessageCount
    case InvalidRecordsCount
}
