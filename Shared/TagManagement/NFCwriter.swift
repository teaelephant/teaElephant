//
// Created by Andrew Khasanov on 18.07.2020.
//

import Foundation
import CoreNFC
import UIKit
import MessagePacker

class tagWriter: NSObject, ShortInfoWriter {
    var nfc: NearFieldCommunicator!
    var message: NFCNDEFMessage?

    override init() {
        super.init()
        nfc = NearFieldCommunicator(delegate: self)
    }

    public func writeData(info: TeaMeta) throws {
        guard NFCTagReaderSession.readingAvailable else {
            print("Scanning Not Supported")
            return
        }
        var data: Data
        do {
            data = try info.toBytes()
        } catch {
            print(error.localizedDescription)
            throw error
        }
        print("data \(String(describing: String(data: data, encoding: String.Encoding.utf8)))")
        print("info \(info)")
        let payload = NFCNDEFPayload(format: NFCTypeNameFormat.nfcWellKnown, type: "application/json".data(using: .utf8)!, identifier: Data.init(count: 0), payload: data)
        message = NFCNDEFMessage(records: [payload])
        self.nfc.createSession()
        print(message ?? "")
        /*session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
        session?.begin()*/
    }

    /*func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("reading")
        for message in messages {
            for record in message.records {
                if let string = String(data: record.payload, encoding: .ascii) {
                    print(string)
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("readerSessionDidBecomeActive")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        print("writing")
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        // Connect to the found tag and write an NDEF message to it.
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }

            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "Tag is read only."
                    session.invalidate()
                case .readWrite:
                    tag.writeNDEF(self.message!, completionHandler: { (error: Error?) in
                        if nil != error {
                            session.alertMessage = "Write NDEF message fail: \(error!)"
                        } else {
                            session.alertMessage = "Write NDEF message successful."
                        }
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
            })
        })
    }*/
}

extension tagWriter: NFCProtocol {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("read")
    }


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
        print("\(error)")

        // 204 is a raised when a single read is completed.
        guard let err = error as? NFCReaderError, err.code != NFCReaderError.Code(rawValue: 204) else {
            return
        }
        DispatchQueue.main.async {
            /*let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)*/
        }
    }

    /*!
     * @method readerSession:didDetectTags:
     *
     * @param session   The session object used for tag detection.
     * @param tags      Array of @link NFCTag @link/ objects.
     *
     * @discussion      Gets called when the reader detects NFC tag(s) in the polling sequence.
     */
    @available(iOS 13.0, *)
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        print("writing")
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        // Connect to the found tag and write an NDEF message to it.
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }

            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "Tag is read only."
                    session.invalidate()
                case .readWrite:
                    print(self.message!)
                    tag.writeNDEF(self.message!, completionHandler: { (error: Error?) in
                        if let err = error {
                            session.alertMessage = "Write NDEF message fail: \(err)"
                        } else {
                            session.alertMessage = "Write NDEF message successful."
                        }
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
            })
        })
    }
}
