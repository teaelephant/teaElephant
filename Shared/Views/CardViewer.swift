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
			if readQRCode {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
					switch result {
					case .success(let code):
                        processQR(code.string)
						readQRCode = false
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
					Text("Прочтиать содержимое NFC метки").padding(10)
				}
				Button(action: {
					withAnimation {
						readQR()
					}
				}) {
					Text("Прочтиать содержимое QR кода").padding(10)
				}

			}
		}
	}

	private func processQR(_ code: String) {
		reader.processQRCode(code)
		print("Прочитано.")
	}

	func readNFC() {
		reader.readInfo()
		print("Прочитано.")
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
