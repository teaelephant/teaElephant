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
                    manager.recomendation(id, feelings:feelings)
                }
            }, label: {
                Text("Get recomendation")
            }).animation(.default, value: manager.recomendationLoading)
            if manager.recomendationLoading {
                ProgressView()
            } else if let text = manager.lastRecomendation {
                Text(LocalizedStringKey(text)).animation(.interactiveSpring, value: manager.lastRecomendation)
            }
        }
    }
}

#Preview {
    RecomendationUIView(id: "", manager: CollectionsManager())
}
