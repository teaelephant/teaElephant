//
//  NotificationUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 29/08/2023.
//

import SwiftUI

struct NotificationUIView: View {
    @ObservedObject var appState = AppState.shared
    @State var navigate = false
    
    var pushNavigationBinding : Binding<Bool> {
        .init { () -> Bool in
            appState.pageToNavigationTo != nil
        } set: { (newValue) in
            if !newValue { appState.pageToNavigationTo = nil }
        }
    }
    
    var body: some View {
        NavigationView {
            Text("My content")
                .overlay(NavigationLink(destination: DestinatoinUIView(id: appState.id ?? "", message: appState.notificationMessage ?? ""),
                                        isActive: pushNavigationBinding) {
                    EmptyView()
                })
        }
    }
}

#Preview {
    NotificationUIView()
}
