//
//  AppState.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 29/08/2023.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pageToNavigationTo : Destination?
    @Published var notificationMessage: String?
    @Published var id: String?
}

enum Destination {
    case showCard
    case showCollection
}
