//
//  NearFieldCommunicator.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import Foundation
@preconcurrency import CoreNFC


typealias NFCCallback = ([NFCNDEFMessage]) -> Void

protocol NFCProtocol: NFCNDEFReaderSessionDelegate {
    func ready() -> Void
}

@MainActor
class NearFieldCommunicator: NSObject {
    var session: NFCNDEFReaderSession?
    weak var delegate: NFCProtocol?

    init(delegate: NFCProtocol) {
        self.delegate = delegate
        super.init()
    }

    func createSession(invalidateAfterFirstRead: Bool = true) {
        invalidateSession()
        guard let delegate else { return }
        let newSession = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: invalidateAfterFirstRead)
        session = newSession
        newSession.alertMessage = "Приложи телефон к баночке с чаем чтобы узнать что в ней"
        newSession.begin()
    }

    func ready() {
        guard let session else { return }
        if session.isReady {
            session.begin()
        } else {
            let sessionBox = SendableBox(session)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self, self.session === sessionBox.value else { return }
                self.ready()
            }
        }
    }

    func invalidateSession() {
        let completedSession = session
        session = nil
        completedSession?.invalidate()
    }
}
