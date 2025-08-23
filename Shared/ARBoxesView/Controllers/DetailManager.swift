//
//  DetailManager.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10/08/2023.
//

import Foundation
import SwiftUI

@MainActor
class DetailManager: ObservableObject {
    @Published var info: TeaInfo?
}
