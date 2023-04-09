//
//  NewCard.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import SwiftUI
import Combine
import CodeScanner
import UIKit
import TeaElephantSchema

struct NewCard: View {
	@Environment(\.presentationMode) var presentationMode
	@ObservedObject private var searcher = Searcher(Search())
	@State private var name = ""
	@State private var type = Type.tea
	@State private var description = ""
    @State private var expirationDate = Foundation.Date.init()
	@State private var brewingTemp: String = "100"
	@State private var readQRCode = false
	var body: some View {
		#if APPCLIP
		FullAppOffer()
		#else
		if readQRCode {
			CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
				switch result {
				case .success(let code):
                    saveQR(code.string)
					readQRCode = false
				case .failure(let error):
					print(error.localizedDescription)
					readQRCode = false
				}
			}
		} else {
			ScrollView {
				VStack(alignment: .center, spacing: 20) {

					HStack {
						Text("Имя")
						TextField("Имя", text: $name)
										.onChange(of: name, perform: search)
										.textFieldStyle(RoundedBorderTextFieldStyle())
										.multilineTextAlignment(.trailing)
					}.zIndex(1.0)
					if $searcher.detectedInfo.wrappedValue != nil {
						Name(name: ($searcher.detectedInfo.wrappedValue?.data.name)!)
                        TypeView(type: ($searcher.detectedInfo.wrappedValue?.data.type.value)!)
						Description(description: ($searcher.detectedInfo.wrappedValue?.data.description)!)
					} else {
						Picker(selection: $type, label: Text("Тип напитка")) {
							Text(Type.tea.rawValue).tag(1)
							Text(Type.coffee.rawValue).tag(2)
							Text(Type.herb.rawValue).tag(3)
						}.frame(height: 100)
						HStack {
							Text("Описание")
							TextEditor(text: $description)
											.textFieldStyle(RoundedBorderTextFieldStyle())
											.multilineTextAlignment(.trailing)
											.lineLimit(5)
						}.frame(height: 150)
					}
					DatePicker("Срок годности", selection: $expirationDate, displayedComponents: [.date]).frame(height: 50)
					HStack {
						Text("Температура заваривания")
						TextField("Температура заваривания", text: $brewingTemp)
										.textFieldStyle(RoundedBorderTextFieldStyle())
										.multilineTextAlignment(.trailing)
					}
					Spacer()
					Button(action: {
						withAnimation {
							saveNFC()
						}
					}) {
						Text("Сохранить на NFC метку").padding(10)
					}
					Button(action: {
						withAnimation {
							getQR()
						}
					}) {
						Text("Сохранить на QR код").padding(10)
					}
				}.padding()
			}.keyboardAdaptive()
		}
		#endif
	}


	func saveNFC() {
		if $searcher.detectedInfo.projectedValue.wrappedValue != nil {
			do {
				try tagWriter().writeData(info: $searcher.detectedInfo.projectedValue.wrappedValue!.meta)
				name = ""
			} catch {
				print(error.localizedDescription)
			}
			return
		}
		var formatter: NumberFormatter {
			let nf = NumberFormatter()
			nf.numberStyle = .currency
			nf.isLenient = true
			return nf
		}
		var temp: Int
		guard let n = formatter.number(from: brewingTemp) else {
			print("Температура заваривания - не число")
			return
		}
		temp = n.intValue
		print(temp)

		let data = TeaData(
						name: name,
						type: GraphQLEnum(Type(rawValue: type.rawValue)!),
						description: description
		)
		do {
			let w = writer(extend: RecordWriter(), meta: tagWriter())
			try w.write(data, expirationDate: expirationDate, brewingTemp: temp)
		} catch {
			print(error.localizedDescription)
			return
		}
		resetState()
		presentationMode.wrappedValue.dismiss()
		print("Сохранено")
	}

	private func search(_ prefix: String) {
		print("search: " + prefix)
		if prefix != "" {
			searcher.search(prefix: prefix)
		}
	}

	private func resetState() {
		name = ""
		type = Type.tea
		description = ""
		expirationDate = Date.init()
		brewingTemp = "100"
	}

	private func getQR() {
		readQRCode = true
	}

	private func saveQR(_ code: String) {
		if $searcher.detectedInfo.projectedValue.wrappedValue != nil {
			QRManager().write(id: code, data: $searcher.detectedInfo.projectedValue.wrappedValue!.meta)
			name = ""
			return
		}
		var formatter: NumberFormatter {
			let nf = NumberFormatter()
			nf.numberStyle = .currency
			nf.isLenient = true
			return nf
		}
		var temp: Int
		guard let n = formatter.number(from: brewingTemp) else {
			print("Температура заваривания - не число")
			return
		}
		temp = n.intValue
		print(temp)

		let data = TeaData(
						name: name,
						type: GraphQLEnum(Type(rawValue: type.rawValue)!),
						description: description
		)
		do {
			let w = writer(extend: RecordWriter(), meta: tagWriter())
			try w.write(data, expirationDate: expirationDate, brewingTemp: temp)
		} catch {
			print(error.localizedDescription)
			return
		}
		resetState()
		presentationMode.wrappedValue.dismiss()
		print("Сохранено")
	}
}

extension View {
	func keyboardAdaptive() -> some View {
		ModifiedContent(content: self, modifier: KeyboardAdaptive())
	}
}

struct KeyboardAdaptive: ViewModifier {
	@State private var bottomPadding: CGFloat = 0

	func body(content: Content) -> some View {
		// 1.
		GeometryReader { geometry in
			content
							.padding(.bottom, bottomPadding)
							// 2.
							.onReceive(Publishers.keyboardHeight) { keyboardHeight in
								// 3.
								let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
								// 4.
								let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
								// 5.
								self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
							}
							// 6.
							.animation(.easeOut(duration: 0.16))
		}
	}
}

struct NewCard_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			NewCard()
		}
	}
}
