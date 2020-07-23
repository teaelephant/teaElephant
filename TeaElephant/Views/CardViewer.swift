//
//  CardViewer.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 22.07.2020.
//

import SwiftUI

struct CardViewer: View {
    @ObservedObject private var reader = Reader()
    var body: some View {
        VStack{
            ShowCard(info: $reader.detectedInfo)
            Spacer()
            Button(action: {
                withAnimation {
                    self.read()
                }
            }) {
                Text("Прочтиать содержимое").padding(10)
            }
        }
    }
    func read() {
        reader.start()
        print("Прочитано.")
    }
}

struct CardViewer_Previews: PreviewProvider {
    static var previews: some View {
        CardViewer()
    }
}
