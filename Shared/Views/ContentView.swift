//
//  ContentView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 16.07.2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Menu()
        }
        .eraseToAnyView()
    }

    #if DEBUG
    @ObservedObject var iO = injectionObserver
    #endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
