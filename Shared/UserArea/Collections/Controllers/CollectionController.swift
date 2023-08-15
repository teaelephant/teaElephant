//
//  CollectionController.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 11/08/2023.
//

import Foundation

class CollectionManager: ObservableObject {
    @Published var teas: [TeaElephantSchema.CollectionsQuery.Data.Collection]?
    @Published var error: Error?
    
    func getCollections(forceReload: Bool = false) async {
        let cachePolicy: CachePolicy = forceReload ? .fetchIgnoringCacheData : .returnCacheDataElseFetch
        do {
            for try await result in Network.shared.apollo.fetchAsync(query: CollectionsQuery(token: ""), cachePolicy: cachePolicy) {
                if let errors = result.errors {
                    self.error = errors.first
                    return
                }
                guard let cols = result.data?.collections else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.collections = cols
                }
            }
        } catch {
            self.error = error
        }
    }
    
    func addCollection(name: String) async {
        let result = await Network.shared.apollo.performAsync(mutation: CreateCollectionMutation(
                name: name, token: ""
        ))
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
                do {
                    try self.collections?.append(CollectionsQuery.Data.Collection(data: col.__data._data))
                } catch {
                    print(error)
                }
            }
        case .failure(let error):
            print(error)
        }
        await getCollections(forceReload: true)
    }
}
