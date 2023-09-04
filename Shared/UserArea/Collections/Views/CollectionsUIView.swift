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
                if manager.collectionsLoading {
                    ProgressView().onAppear{
                        Task{
                            await manager.getCollections()
                        }
                    }
                } else {
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
                        ForEach($manager.collections, id: \.id) { $el in
                            NavigationLink(el.name, destination: CollectionUIView(manager: manager, collection: $el))
                        }.onDelete(perform: { indexSet in
                            for index in indexSet {
                                Task{
                                    let cols = manager.collections
                                    await manager.deleteCollection(id:cols[index].id)
                                }
                            }
                        })
                    }.refreshable {
                        Task{
                            await manager.getCollections(forceReload: true)
                        }
                    }.navigationBarTitle("Collections")
                }
            }
            
        }
    }
}

struct CollectionsUIView_Previews: PreviewProvider {
    static var previews: some View {
        
        if #available(iOS 17.0, *) {
            CollectionsUIView(manager: CollectionsManager())
        } else {
            Text("Unsupported")
        }
    }
}
