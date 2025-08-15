//
//  TeaRepository.swift
//  TeaElephant
//
//  Repository implementation for tea operations
//

import Foundation
import TeaElephantSchema

@MainActor
final class TeaRepository: TeaRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchTea(by id: String) async throws -> TeaDataWithID {
        let data = try await networkService.fetch(
            TeaQuery(id: id),
            cachePolicy: .returnCacheDataElseFetch
        )
        
        guard let tea = data.tea else {
            throw AppError.teaNotFound
        }
        
        return TeaDataWithID(
            ID: tea.id,
            name: tea.name,
            type: .tea,
            description: tea.description ?? ""
        )
    }
    
    func searchTea(query: String) async throws -> [TeaDataWithID] {
        let data = try await networkService.fetch(
            SearchTeaQuery(query: query),
            cachePolicy: .fetchIgnoringCacheData
        )
        
        guard let teas = data.searchTea else {
            return []
        }
        
        return teas.map { tea in
            TeaDataWithID(
                ID: tea.id,
                name: tea.name,
                type: .tea,
                description: tea.description ?? ""
            )
        }
    }
    
    func createTea(_ tea: TeaDataWithID) async throws -> TeaDataWithID {
        let data = try await networkService.perform(
            CreateTeaMutation(
                name: tea.name,
                description: tea.description
            )
        )
        
        guard let createdTea = data.createTea else {
            throw AppError.dataCorrupted
        }
        
        return TeaDataWithID(
            ID: createdTea.id,
            name: createdTea.name,
            type: .tea,
            description: createdTea.description ?? ""
        )
    }
}