//
//  CollectionUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 11/08/2023.
//

import SwiftUI
import TeaElephantSchema

@available(iOS 17.0, *)
struct CollectionUIView: View {
    @ObservedObject private var manager = CollectionsManager()
    @State private var detectForAdd = false
    @State private var newIDs = [String]()
    var id: String
    var name: String
    var records: [CollectionsQuery.Data.Collection.Record]
    var body: some View {
        if detectForAdd {
            HStack{
                Text("\(newIDs.count)").foregroundStyle(.blue).bold()
                Button(action: {
                    Task{
                        detectForAdd = false
                        await manager.addRecordsToCollection(id, newIDs: newIDs)
                        newIDs = [String]()
                    }
                }) {
                    Text("Add to collection")
                }
            }
            Detector2(callback: self.appendIds).edgesIgnoringSafeArea(.all)
        } else {
            List(records, id: \.id) { el in
                Text("\(el.tea.name)")
            }.navigationBarTitle("Collection \(name)").toolbar{
                Button(action: {
                    detectForAdd = true
                }) {
                    Text("Add teas")
                }
            }
        }
    }
    
    func appendIds(_ newID: String) {
        self.newIDs.append(newID)
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        NavigationStack {
            CollectionUIView(id: "565b482a-5034-474f-becc-666fb559ba67", name: "home", records: [])
        }
    } else {
        Text("Unsupported")
    }
}
