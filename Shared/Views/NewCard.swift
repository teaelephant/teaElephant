//
//  NewCard.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import SwiftUI
import Combine
import UIKit

struct NewCard: View {
    @ObservedObject private var searcher = Searcher(Api("https://te.xax.cloud"))
    @State private var name = ""
    @State private var type = TeaType.tea
    @State private var description = ""
    @State private var expirationDate = Date.init()
    @State private var brewingTemp: String = "100"
    var body: some View {
        #if APPCLIP
        FullAppOffer()
        #else
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Имя")
                    TextField("Имя", text: $name)
                            .onChange(of: name, perform: search)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                }.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                if $searcher.detectedInfo.wrappedValue != nil {
                    Name(name: ($searcher.detectedInfo.wrappedValue?.data.name)!)
                    Type(type: ($searcher.detectedInfo.wrappedValue?.data.type)!)
                    Description(description: ($searcher.detectedInfo.wrappedValue?.data.description)!)
                } else {
                    Picker(selection: $type, label: Text("Тип напитка")) {
                        Text(TeaType.tea.rawValue).tag(1)
                        Text(TeaType.coffee.rawValue).tag(2)
                        Text(TeaType.herb.rawValue).tag(3)
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
                        save()
                    }
                }) {
                    Text("Сохранить").padding(10)
                }
            }.padding()
        }.keyboardAdaptive()
        #endif
    }


    func save() {
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
                type: type,
                description: description
        )
        do {
            let w = writer(extend: Api("https://te.xax.cloud"), meta: tagWriter())
            try w.write(data, expirationDate: expirationDate, brewingTemp: temp)
        } catch {
            print(error.localizedDescription)
            return
        }
        resetState()
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
        type = TeaType.tea
        description = ""
        expirationDate = Date.init()
        brewingTemp = "100"
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
            NewCard()
        }
    }
}
