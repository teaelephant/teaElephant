//
//  NearFieldCommunicator.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import Foundation
import CoreNFC


typealias NFCCallback = ([NFCNDEFMessage]) -> Void

protocol NFCProtocol: NFCNDEFReaderSessionDelegate {
    func ready() -> Void
}

class NearFieldCommunicator: NSObject {
    var session: NFCNDEFReaderSession!
    let delegate: NFCProtocol

    init(delegate: NFCProtocol) {
        self.delegate = delegate
        super.init()
    }

    func createSession() {
        if let aSession = session {
            aSession.invalidate()
        }
        session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Приложи телефон к баночке с чаем чтобы узнать что в ней"
        self.session.begin()
    }

    func ready() {
        if session.isReady {
            session.begin()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.ready()
            }
        }
    }

    func invalidateSession() {
        session.invalidate()
    }
}
