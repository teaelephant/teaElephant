//
//  CardViewer.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 22.07.2020.
//

import SwiftUI
import os

private let logQR2 = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "QR")
import CodeScanner

struct CardViewer: View {
    @StateObject private var reader = Reader(infoReader: NFCReader(), extender: RecordGetter())
    @State private var readQRCode = false
    var body: some View {
        VStack {
            if let err = reader.error {
                Text("\(err)").foregroundStyle(.red).bold().onAppear{
                    Task{
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        reader.error = nil
                    }
                }
            }
            if readQRCode {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
                    switch result {
                    case .success(let code):
                        Task {
                            await processQR(code.string)
                            readQRCode = false
                        }
                    case .failure(let error):
                        logQR2.error("QR scan error: \(error.localizedDescription, privacy: .public)")
                        readQRCode = false
                    }
                }
            } else {
                EnhancedShowCard(info: $reader.detectedInfo)
                Spacer()
                Button(action: {
                    withAnimation {
                        readNFC()
                    }
                }) {
                    Text("Read NFC tag").padding(10)
                }
                Button(action: {
                    withAnimation {
                        readQR()
                    }
                }) {
                    Text("Read QR code").padding(10)
                }
                
            }
        }
    }
    
    private func processQR(_ code: String) async {
        await reader.processQRCode(code)
        logQR2.info("QR processed successfully")
    }
    
    func readNFC() {
        reader.readInfo()
        logQR2.info("NFC read started")
    }
    
    func readQR() {
        readQRCode = true
    }
}

struct CardViewer_Previews: PreviewProvider {
    static var previews: some View {
        CardViewer()
    }
}
