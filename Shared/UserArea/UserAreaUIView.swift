//
//  UserAreaUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 13/08/2023.
//

import SwiftUI

struct UserAreaUIView: View {
    @ObservedObject private var manager = CollectionsManager()
    
    var body: some View {
        if manager.validateAuth() {
            if #available(iOS 17.0, *) {
                CollectionsUIView(manager: manager)
            } else {
                Text("Unsupported")
            }
        } else {
            AuthUIView(manager: manager)
        }
    }
}

#Preview {
    UserAreaUIView()
}
