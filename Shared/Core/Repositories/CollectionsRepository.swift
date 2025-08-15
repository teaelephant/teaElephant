//
//  CollectionsRepository.swift
//  TeaElephant
//
//  Repository implementation for collections operations
//

import Foundation
import Apollo
import TeaElephantSchema

@MainActor
final class CollectionsRepository: CollectionsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchCollections(forceReload: Bool = false) async throws -> [Collection] {
        let cachePolicy: CachePolicy = forceReload ? .fetchIgnoringCacheData : .returnCacheDataElseFetch
        
        let data = try await networkService.fetch(
            CollectionsQuery(),
            cachePolicy: cachePolicy
        )
        
        guard let collectionsData = data.collections else {
            throw AppError.dataCorrupted
        }
        
        return collectionsData.compactMap { collectionData in
            let records = collectionData.records.map { record in
                Record(
                    id: record.id,
                    data: TeaDataWithID(
                        ID: record.tea.id,
                        name: record.tea.name,
                        type: .tea,
                        description: ""
                    )
                )
            }
            
            return Collection(
                id: collectionData.id,
                name: collectionData.name,
                desc: collectionData.desc,
                isPublic: collectionData.isPublic,
                isLocked: collectionData.locked,
                records: records
            )
        }
    }
    
    func createCollection(_ collection: Collection) async throws -> Collection {
        let data = try await networkService.perform(
            CreateCollectionMutation(
                name: collection.name,
                desc: collection.desc,
                isPublic: collection.isPublic
            )
        )
        
        guard let createdCollection = data.createCollection else {
            throw AppError.dataCorrupted
        }
        
        return Collection(
            id: createdCollection.id,
            name: createdCollection.name,
            desc: createdCollection.desc,
            isPublic: createdCollection.isPublic,
            isLocked: createdCollection.locked,
            records: []
        )
    }
    
    func updateCollection(_ collection: Collection) async throws -> Collection {
        let data = try await networkService.perform(
            UpdateCollectionMutation(
                id: collection.id,
                name: collection.name,
                desc: collection.desc,
                isPublic: collection.isPublic
            )
        )
        
        guard let updatedCollection = data.updateCollection else {
            throw AppError.dataCorrupted
        }
        
        return Collection(
            id: updatedCollection.id,
            name: updatedCollection.name,
            desc: updatedCollection.desc,
            isPublic: updatedCollection.isPublic,
            isLocked: updatedCollection.locked,
            records: collection.records
        )
    }
    
    func deleteCollection(id: String) async throws {
        _ = try await networkService.perform(
            DeleteCollectionMutation(id: id)
        )
    }
    
    func addRecord(to collectionId: String, teaId: String) async throws {
        _ = try await networkService.perform(
            CreateRecordMutation(
                collectionId: collectionId,
                teaId: teaId
            )
        )
    }
    
    func removeRecord(from collectionId: String, recordId: String) async throws {
        _ = try await networkService.perform(
            DeleteRecordMutation(id: recordId)
        )
    }
}