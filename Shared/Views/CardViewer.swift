//
//  CardViewer.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 22.07.2020.
//

import SwiftUI
import CodeScanner

struct CardViewer: View {
    @ObservedObject private var reader = Reader(infoReader: NFCReader(), extender: RecordGetter())
    @State private var readQRCode = false
    var body: some View {
        VStack {
            if let err = reader.error {
                if #available(iOS 16.0, *) {
                    Text("\(err)").foregroundStyle(.red).bold().onAppear{
                        Task{
                            try await Task.sleep(nanoseconds: 5_000_000_000)
                            reader.error = nil
                        }
                    }
                } else {
                    Text("\(err)").foregroundColor(.red).bold().onAppear{
                        Task{
                            try await Task.sleep(nanoseconds: 5_000_000_000)
                            reader.error = nil
                        }
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
                        print(error.localizedDescription)
                        readQRCode = false
                    }
                }
            } else {
                ShowCard(info: $reader.detectedInfo)
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
        print("Read successfully")
    }
    
    func readNFC() {
        reader.readInfo()
        print("Read successfully")
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
