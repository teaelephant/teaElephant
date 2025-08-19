//
//  CollectionsManagement.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 11/08/2023.
//

import Foundation
@preconcurrency import Apollo
import SwiftUI
@preconcurrency import TeaElephantSchema
import os
import KeychainSwift

@MainActor
final class CollectionsManager: ObservableObject {
    @Published var collections: [Collection] = [Collection]()
    @Published var error: Error?
    @Published var collectionsLoading = false
    @Published var lastRecomendation:String?
    @Published var recommendationsStack:String?
    @Published var recomendationLoading = false
    var subscribeRecommendation: Cancellable?
    let log = Logger(subsystem: "xax.TeaElephant", category: "CollectionManager")
    
    deinit {
        subscribeRecommendation?.cancel()
    }
    
    func getCollections(forceReload: Bool = false) async {
        let cachePolicy: CachePolicy = forceReload ? .fetchIgnoringCacheData : .returnCacheDataElseFetch
        collectionsLoading = true
        log.debug("Starting getCollections, forceReload: \(forceReload)")
        do {
            for try await result in Network.shared.apollo.fetchAsync(query: CollectionsQuery(), cachePolicy: cachePolicy) {
                if let errors = result.errors {
                    log.error("getCollections error: \(errors)")
                    DispatchQueue.main.async {
                        self.error = errors.first
                        self.collectionsLoading = false
                    }
                    // Check if it's an auth error
                    if let code = errors.first?.extensions?["code"] as? Int, code == -1 {
                        log.debug("Auth error detected, setting auth to false")
                        AuthManager.shared.auth = false
                    }
                    return
                }
                guard let cols = result.data?.collections else {
                    log.debug("No collections data received")
                    DispatchQueue.main.async {
                        self.collectionsLoading = false
                    }
                    return
                }
                
                log.debug("Received \(cols.count) collections")
                DispatchQueue.main.async {
                    // Clear and rebuild the collections array to ensure deleted items are removed
                    var newCollections: [Collection] = []
                    for col in cols {
                        let records = col.records.map { record in
                            Record(id: record.id, data: TeaDataWithID(ID: record.tea.id, name: record.tea.name, type: .tea, description: ""))
                        }
                        newCollections.append(Collection(id: col.id, name: col.name, records: records))
                    }
                    // Replace the entire array with fresh data
                    self.collections = newCollections
                    self.collectionsLoading = false
                    self.log.debug("Updated collections array with \(newCollections.count) items")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.collectionsLoading = false
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
    
    func recomendation(_ id: String, feelings: String) {
        recomendationLoading = true
        self.lastRecomendation = nil
        subscribeRecommendation = Network.shared.apollo.subscribe(subscription: RecommendTeaSubscription(collectionID: id, feelings: feelings)) { result in
            switch result {
            case .success(let graphQLResult):
                DispatchQueue.main.async {
                    if let errors = graphQLResult.errors {
                        print(errors)
                        return
                    }
                    guard let data = graphQLResult.data?.recommendTea else {
                        return
                    }
                    if self.lastRecomendation == nil {
                        self.lastRecomendation = data
                    } else {
                        self.lastRecomendation! += data
                    }
                }
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.recomendationLoading = false
            }
        }
    }
    
    func anotherRecomendation(_ id: String) {
        recomendationLoading = true
        self.lastRecomendation = nil
        subscribeRecommendation = Network.shared.apollo.subscribe(subscription: RecommendTeaSubscription(collectionID: id, feelings: "")) { result in
            switch result {
            case .success(let graphQLResult):
                DispatchQueue.main.async {
                    if let errors = graphQLResult.errors {
                        print(errors)
                        return
                    }
                    guard let data = graphQLResult.data?.recommendTea else {
                        return
                    }
                    if self.lastRecomendation == nil {
                        self.lastRecomendation = data
                    } else {
                        self.lastRecomendation! += data
                    }
                }
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.recomendationLoading = false
            }
        }
    }
}
