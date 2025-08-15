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
    @ObservedObject var manager: CollectionsManager
    @State private var detectForAdd = false
    @State private var newIDs = [String]()
    @Binding var collection: Collection
    var body: some View {
        if manager.collectionsLoading {
            ProgressView()
        } else {
            if detectForAdd {
                HStack{
                    Text("\(newIDs.count)").foregroundStyle(.blue).bold()
                    Button(action: {
                        Task{
                            detectForAdd = false
                            await manager.addRecordsToCollection(collection.id, newIDs: newIDs)
                            newIDs = [String]()
                        }
                    }) {
                        Text("Add to collection")
                    }
                }
#if APPCLIP
                FullAppOffer()
#elseif !targetEnvironment(simulator)
                QRDetector(callback: self.appendIds).edgesIgnoringSafeArea(.all)
#else
                Text("AR View not accessible in simulator")
#endif
                
                
            } else if collection.records.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Empty Collection")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Add teas by scanning NFC tags or QR codes")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Button(action: {
                        detectForAdd = true
                    }) {
                        Label("Scan Tea Tags", systemImage: "qrcode.viewfinder")
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .navigationBarTitle("Collection \(collection.name)")
                .toolbar{
                    NavigationLink("Recommend tea", destination: RecomendationUIView(id: collection.id, manager: manager))
                }
            } else {
                List{
                    ForEach($collection.records, id: \.id) { $el in
                        Text("\(el.data.name)")
                    }.onDelete(perform: { indexSet in
                        let recordsForDelete = indexSet.map { index in
                            if collection.records.count <= index {
                                return ""
                            }
                            return collection.records[index].id
                        }
                        
                        Task{
                            await manager.deleteRecordsFromCollection(collection.id, records: recordsForDelete)
                        }
                    })
                }.navigationBarTitle("Collection \(collection.name)").toolbar{
                    Button(action: {
                        detectForAdd = true
                    }) {
                        Text("Add teas")
                    }
                    NavigationLink("Recommend tea", destination: RecomendationUIView(id: collection.id, manager: manager))
                }
            }
        }
    }
    
    func appendIds(_ newID: String) {
        self.newIDs.append(newID)
    }
}

struct CollectionUIView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            NavigationStack {
                CollectionUIView(manager: CollectionsManager(), collection: .constant(Collection(id: "", name: "", records: [Record]())))
            }
        } else {
            Text("Unsupported")
        }
    }
}
