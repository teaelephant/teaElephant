//
//  CollectionsUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 11/08/2023.
//

import SwiftUI
import TeaElephantSchema

@available(iOS 17.0, *)
struct CollectionsUIView: View {
    @ObservedObject var manager: CollectionsManager
    @State private var name = ""
    var body: some View {
        VStack{
            if let error = manager.error {
                Text("netowrk error \(error.localizedDescription)").foregroundStyle(.red)
            }
            NavigationStack {
                List{
                    HStack{
                        TextField("Name of new collection", text: $name).padding(.horizontal)
                        Button(action: {
                            Task{
                                await manager.addCollection(name: name)
                                name = ""
                            }
                        }) {
                            Image(systemName: "plus")
                        } .disabled(name == "").foregroundColor(.green).bold()
                    }
                    if let cols = manager.collections {
                        ForEach(cols, id: \.id) { el in
                            NavigationLink(el.name, value: el)
                        }.onDelete(perform: { indexSet in
                            for index in indexSet {
                                Task{
                                    await manager.deleteCollection(id:cols[index].id)
                                }
                            }
                        })
                    } else {
                        ProgressView().onAppear{
                            Task{
                                await manager.getCollections()
                            }
                        }
                    }
                }.refreshable {
                    Task{
                        await manager.getCollections(forceReload: true)
                    }
                }.navigationDestination(for: CollectionsQuery.Data.Collection.self) { el in
                    CollectionUIView(id:el.id, name: el.name, records:el.records)
                }.navigationBarTitle("Collections")
            }
            
        }
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        CollectionsUIView(manager: CollectionsManager())
    } else {
        Text("Unsupported")
    }
}
