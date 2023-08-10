//
//  menager.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 18.07.2020.
//

import Foundation
import SwiftUI
import UIKit
import CoreNFC
import MessagePacker

class NFCReader: NSObject, ObservableObject, ShortInfoReader {
    var nfc: NearFieldCommunicator!
    private var onRead: ((_ meta: TeaMeta) async -> Void)?
    @Published var detectedInfo: TeaMeta?
    @Published var error: Error?

    override init() {
        super.init()
        nfc = NearFieldCommunicator(delegate: self)
    }
    
    func setOnRead(_ onRead: @escaping (_ meta: TeaMeta) async -> Void) {
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

extension NFCReader: NFCProtocol {

    func ready() -> Void {
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
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                       && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }

        // To read new tags, a new session instance is required.
        self.nfc.createSession()
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
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("\(messages)")
        DispatchQueue.main.async {
            if messages.count != 1 {
                print("invalid message count")
                self.error = ReaderError("invalid message count")
                return
            }
            if messages[0].records.count != 1 {
                print("invalid records count")
                self.error = ReaderError("invalid records count")
                return
            }
            Task {
                do {
                    self.detectedInfo = try TeaMeta.fromBytes(data: messages[0].records[0].payload)
                    if self.onRead != nil && self.detectedInfo != nil {
                        await self.onRead!(self.detectedInfo!)
                    }
                } catch {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
}

struct ReaderError: Error {
    var message: String
    init(_ message: String) {
        self.message = message
    }
}
