//
//  UserAreaUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 13/08/2023.
//

import SwiftUI

struct UserAreaUIView: View {
    @ObservedObject private var manager = CollectionsManager()
    @ObservedObject var authManager = AuthManager()
    
    var body: some View {
        if authManager.loading {
            VStack(spacing: 16) {
                ProgressView()
                Text("Checking authentication...")
                    .foregroundColor(.secondary)
            }
            .onAppear{
                Task{
                    await authManager.authorized()
                }
            }
        } else if authManager.auth {
            if #available(iOS 18.0, *) {
                CollectionsUIView(manager: manager)
                
            } else {
                Text("Unsupported")
            }
        } else {
            AuthUIView()
        }
    }
}

struct UserAreaUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserAreaUIView(authManager: AuthManager.shared)
    }
}
