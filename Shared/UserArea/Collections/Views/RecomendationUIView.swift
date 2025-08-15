//
//  RecomendationUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 01/09/2023.
//

import SwiftUI
import TeaElephantSchema

struct RecomendationUIView: View {
    var id: String
    @ObservedObject var manager: CollectionsManager
    @State private var feelings = ""
    @State private var type = Type_Enum.unknown
    @State private var withAdditives = true
    var body: some View {
        ScrollView{
            HStack {
                Picker(selection: $type, label: Text("Type of")) {
                    Text("Any").tag(Type_Enum.unknown)
                    Text(Type_Enum.tea.rawValue).tag(Type_Enum.tea)
                    Text(Type_Enum.coffee.rawValue).tag(Type_Enum.coffee)
                    Text(Type_Enum.herb.rawValue).tag(Type_Enum.herb)
                }.padding(.horizontal, 20)
                Spacer()
                Toggle(isOn: $withAdditives){
                    Text("Additives")
                }.padding(.horizontal, 20)
            }
            HStack {
                TextField("Feelings", text: $feelings).padding(.horizontal, 20)
                Button(action: {
                    Task{
                        manager.recomendation(id, feelings:feelings)
                    }
                }, label: {
                    Image(systemName: "arrowshape.up.circle.fill")
                }).animation(.default, value: manager.recomendationLoading).padding(.horizontal, 20)
            }
            if manager.recomendationLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("AI is thinking about your perfect tea...")
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .italic()
                }
                .padding(.top, 40)
            } else if let text = manager.lastRecomendation {
                Text(LocalizedStringKey(text)).animation(.interactiveSpring, value: manager.lastRecomendation)
                Button(action:{
                    Task {
                        manager.anotherRecomendation(id)
                    }
                }, label: {
                    Image(systemName:"arrow.clockwise.circle.fill")
                }).animation(.default, value: manager.recomendationLoading)
            }
        }
    }
}

#Preview {
    RecomendationUIView(id: "", manager: CollectionsManager())
}
