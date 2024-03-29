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

@available(iOS 13.0.0, *)
struct NewCard: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var searcher = Searcher(Search())
    @State private var name = ""
    @State private var type = Type_Enum.tea
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
                    Task{
                        await saveQR(code.string)
                        readQRCode = false
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    readQRCode = false
                }
            }
        } else {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    
                    HStack {
                        Text("Name")
                        TextField("Name", text: $name)
                            .onChange(of: name, perform: search)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                    }.zIndex(1.0)
                    if let searchData = $searcher.detectedInfo.wrappedValue {
                        Name(name: (searchData.data.name))
                        TypeView(type: (searchData.data.type.value) ?? Type_Enum.other)
                        Description(description: (searchData.data.description))
                    } else {
                        Picker(selection: $type, label: Text("Type of")) {
                            Text(Type_Enum.tea.rawValue).tag(Type_Enum.tea)
                            Text(Type_Enum.coffee.rawValue).tag(Type_Enum.coffee)
                            Text(Type_Enum.herb.rawValue).tag(Type_Enum.herb)
                        }.frame(height: 100)
                        HStack {
                            Text("Description")
                            TextEditor(text: $description)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .multilineTextAlignment(.trailing)
                                .lineLimit(5)
                        }.frame(height: 150)
                    }
                    DatePicker("Use until", selection: $expirationDate, displayedComponents: [.date]).frame(height: 50)
                    HStack {
                        Text("Boiling temperature")
                        TextField("Boiling temperature", text: $brewingTemp)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                    }
                    Spacer()
                    Button(action: {
                        Task{
                            await saveNFC()
                        }
                    }) {
                        Text("Save to NFC tag").padding(10)
                    }
                    Button(action: {
                        withAnimation {
                            getQR()
                        }
                    }) {
                        Text("Save to QR code").padding(10)
                    }
                }.padding()
            }.keyboardAdaptive()
        }
#endif
    }
    
    
    func saveNFC() async {
        if let searcherData = $searcher.detectedInfo.projectedValue.wrappedValue {
            do {
                try tagWriter().writeData(info: searcherData.meta)
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
            type: GraphQLEnum(Type_Enum(rawValue: type.rawValue)!),
            description: description
        )
        do {
            let w = writer(extend: RecordWriter(), meta: tagWriter())
            try await w.write(data, expirationDate: expirationDate, brewingTemp: temp)
        } catch {
            print(error.localizedDescription)
            return
        }
        resetState()
        presentationMode.wrappedValue.dismiss()
        print("Сохранено")
    }
    
    private func search(_ prefix: String) {
        Task {
            print("search: " + prefix)
            if prefix != "" {
                await searcher.search(prefix: prefix)
            }
        }
    }
    
    private func resetState() {
        name = ""
        type = Type_Enum.tea
        description = ""
        expirationDate = Date.init()
        brewingTemp = "100"
    }
    
    private func getQR() {
        readQRCode = true
    }
    
    private func saveQR(_ code: String) async {
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
        if let searcherData = $searcher.detectedInfo.projectedValue.wrappedValue {
            await QRManager().write(id: code, data: TeaMeta(id: searcherData.meta.id, expirationDate: expirationDate, brewingTemp: temp))
            name = ""
            return
        }
        
        let data = TeaData(
            name: name,
            type: GraphQLEnum(Type_Enum(rawValue: type.rawValue)!),
            description: description
        )
        do {
            let id = try await RecordWriter().writeExtendInfo(info: data)
            print(id)
            let meta = TeaMeta(id: id, expirationDate: expirationDate, brewingTemp: temp)
            
            await QRManager().write(id: code, data: meta)
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
