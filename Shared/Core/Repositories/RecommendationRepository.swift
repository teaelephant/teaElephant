//
//  RecommendationRepository.swift
//  TeaElephant
//
//  Repository implementation for recommendation operations
//

import Foundation
import Combine
import TeaElephantSchema

@MainActor
final class RecommendationRepository: RecommendationRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getRecommendation(for feeling: String) async throws -> String {
        let data = try await networkService.perform(
            RecommendMutation(input: feeling)
        )
        
        guard let recommendation = data.recommendation else {
            throw AppError.dataCorrupted
        }
        
        return recommendation
    }
    
    func subscribeToRecommendations() -> AnyPublisher<String, Error> {
        networkService.subscribe(RecommendationSubscription())
            .compactMap { $0.recommendation }
            .eraseToAnyPublisher()
    }
}