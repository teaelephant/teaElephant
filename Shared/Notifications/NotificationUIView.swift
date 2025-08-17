//
//  NotificationUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 29/08/2023.
//

import SwiftUI

struct NotificationUIView: View {
    @ObservedObject var appState = AppState.shared
    @State private var showingDestination = false
    
    var body: some View {
        NavigationStack {
            Text("My content")
                .onChange(of: appState.pageToNavigationTo) { _, newValue in
                    showingDestination = (newValue != nil)
                }
                .navigationDestination(isPresented: $showingDestination) {
                    DestinatoinUIView(id: appState.id ?? "", message: appState.notificationMessage ?? "")
                }
        }
    }
}

#Preview {
    NotificationUIView()
}
