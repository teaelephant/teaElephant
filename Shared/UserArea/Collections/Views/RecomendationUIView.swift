//
//  RecomendationUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 01/09/2023.
//

import SwiftUI

struct RecomendationUIView: View {
    var id: String
    @ObservedObject var manager: CollectionsManager
    @State private var feelings = ""
    var body: some View {
        ScrollView{
            TextField("Feelings", text: $feelings)
            Button(action: {
                Task{
                    await manager.recomendation(id, feelings:feelings)
                }
            }, label: {
                Text("Get recomendation")
            })
            if let text = manager.lastRecomendation {
                Text(text)
            }
        }
    }
}

#Preview {
    RecomendationUIView(id: "", manager: CollectionsManager())
}
