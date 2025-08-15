//
//  DependencyContainer.swift
//  TeaElephant
//
//  Dependency injection container for managing app dependencies
//

import Foundation
import SwiftUI

protocol DependencyContainerProtocol {
    var networkService: NetworkServiceProtocol { get }
    var authManager: AuthManager { get }
    var collectionsRepository: CollectionsRepositoryProtocol { get }
    var teaRepository: TeaRepositoryProtocol { get }
    var recommendationRepository: RecommendationRepositoryProtocol { get }
}

@MainActor
final class DependencyContainer: ObservableObject, DependencyContainerProtocol {
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(apolloClient: Network.shared.apollo)
    }()
    
    lazy var authManager: AuthManager = {
        AuthManager(networkService: networkService)
    }()
    
    lazy var collectionsRepository: CollectionsRepositoryProtocol = {
        CollectionsRepository(networkService: networkService)
    }()
    
    lazy var teaRepository: TeaRepositoryProtocol = {
        TeaRepository(networkService: networkService)
    }()
    
    lazy var recommendationRepository: RecommendationRepositoryProtocol = {
        RecommendationRepository(networkService: networkService)
    }()
    
    static let shared = DependencyContainer()
    
    private init() {}
}

struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = .shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}