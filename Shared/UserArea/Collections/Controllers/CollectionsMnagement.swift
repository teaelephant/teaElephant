//
//  collectionsMnagement.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 11/08/2023.
//

import Foundation
import Apollo
import TeaElephantSchema
import os
import KeychainSwift

class CollectionsManager: ObservableObject {
    @Published var collections: [Collection] = [Collection]()
    @Published var error: Error?
    @Published var collectionsLoading = true
    @Published var lastRecomendation: String?
    @Published var recomendationLoading = false
    let log = Logger(subsystem: "xax.TeaElephant", category: "CollectionManager")
    
    func getCollections(forceReload: Bool = false) async {
        let cachePolicy: CachePolicy = forceReload ? .fetchIgnoringCacheData : .returnCacheDataElseFetch
        collectionsLoading = true
        do {
            for try await result in Network.shared.apollo.fetchAsync(query: CollectionsQuery(), cachePolicy: cachePolicy) {
                if let errors = result.errors {
                    DispatchQueue.main.async {
                        self.error = errors.first
                    }
                }
                guard let cols = result.data?.collections else {
                    return
                }
                
                
                DispatchQueue.main.async {
                    for col in cols {
                        let records = col.records.map { record in
                            Record(id: record.id, data: TeaDataWithID(ID: record.tea.id, name: record.tea.name, type: .tea, description: ""))
                        }
                        if let index = self.collections.firstIndex(where: {
                            $0.id == col.id
                        }){
                            self.collections[index].records = records
                            self.collections[index].name = col.name
                        } else {
                            self.collections.append(Collection(id: col.id, name: col.name, records: records))
                        }
                        
                    }
                    self.collectionsLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
    
    func addCollection(name: String) async {
        let result = await Network.shared.apollo.performAsync(mutation: CreateCollectionMutation(name: name))
        switch result {
        case .success(let graphQLResult):
            if let errors = graphQLResult.errors {
                print(errors)
                return
            }
            guard let col = graphQLResult.data?.createCollection else {
                return
            }
            DispatchQueue.main.async {
                self.collections.append(Collection(id: col.id, name: col.name, records: [Record]()))
            }
        case .failure(let error):
            print(error)
        }
        await getCollections(forceReload: true)
    }
    
    func deleteCollection(id: String) async {
        let result = await Network.shared.apollo.performAsync(mutation: DeleteCollectionMutation(id: id))
        switch result {
        case .success(let graphQLResult):
            if let errors = graphQLResult.errors {
                print(errors)
                return
            }
        case .failure(let error):
            print(error)
        }
        await getCollections(forceReload: true)
    }
    
    func addRecordsToCollection(_ id: String, newIDs: [String]) async {
        let result = await Network.shared.apollo.performAsync(mutation: AddRecordsToCollectionMutation(id: id, records: newIDs))
        switch result {
        case .success(let graphQLResult):
            if let errors = graphQLResult.errors {
                print(errors)
                return
            }
        case .failure(let error):
            print(error)
        }
        await getCollections(forceReload: true)
    }
    
    
    func deleteRecordsFromCollection(_ id: String, records: [String]) async {
        let result = await Network.shared.apollo.performAsync(mutation: DeleteRecordsFromCollectionMutation(id: id, records: records))
        switch result {
        case .success(let graphQLResult):
            if let errors = graphQLResult.errors {
                print(errors)
                return
            }
        case .failure(let error):
            print(error)
        }
        await getCollections(forceReload: true)
    }
    
    func recomendation(_ id: String, feelings: String) async {
        recomendationLoading = true
        let result = await Network.shared.apollo.performAsync(mutation: TeaRecommendationMutation(collectionID: id, feelings: feelings))
        switch result {
        case .success(let graphQLResult):
            DispatchQueue.main.async {
                if let errors = graphQLResult.errors {
                    print(errors)
                    return
                }
                self.lastRecomendation = graphQLResult.data?.teaRecommendation
            }
        case .failure(let error):
            print(error)
        }
        DispatchQueue.main.async {
            self.recomendationLoading = false
        }
    }
}
