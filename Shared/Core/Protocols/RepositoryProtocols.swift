//
//  RepositoryProtocols.swift
//  TeaElephant
//
//  Repository pattern protocols for data operations
//

import Foundation
import Combine

protocol CollectionsRepositoryProtocol {
    func fetchCollections(forceReload: Bool) async throws -> [Collection]
    func createCollection(_ collection: Collection) async throws -> Collection
    func updateCollection(_ collection: Collection) async throws -> Collection
    func deleteCollection(id: String) async throws
    func addRecord(to collectionId: String, teaId: String) async throws
    func removeRecord(from collectionId: String, recordId: String) async throws
}

protocol TeaRepositoryProtocol {
    func fetchTea(by id: String) async throws -> TeaDataWithID
    func searchTea(query: String) async throws -> [TeaDataWithID]
    func createTea(_ tea: TeaDataWithID) async throws -> TeaDataWithID
}

protocol RecommendationRepositoryProtocol {
    func getRecommendation(for feeling: String) async throws -> String
    func subscribeToRecommendations() -> AnyPublisher<String, Error>
}

protocol AuthRepositoryProtocol {
    func signIn(with appleUserId: String) async throws -> AuthToken
    func signOut() async throws
    func refreshToken() async throws -> AuthToken
    func validateSession() async throws -> Bool
}

struct AuthToken {
    let token: String
    let expiresAt: Date?
}