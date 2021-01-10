//
//  FullAppOffer.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 28.07.2020.
//

import SwiftUI
import StoreKit

struct FullAppOffer: View {
    @State private var showFullApp = false
    var body: some View {
        Text("Install Full App")
            .appStoreOverlay(isPresented: $showFullApp) {
                SKOverlay.AppClipConfiguration(position: .bottom)
            }.onAppear(perform: onload).onDisappear(perform: unload)
    }
    func onload(){
        showFullApp = true
    }
    func unload() {
        showFullApp = false
    }
}

struct FullAppOffer_Previews: PreviewProvider {
    static var previews: some View {
        FullAppOffer()
    }
}
