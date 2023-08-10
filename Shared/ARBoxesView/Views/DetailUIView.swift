//
//  DetailUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10/08/2023.
//

import SwiftUI

struct DetailUIView: View {
    var title: String
    var body: some View {
        Text(title)
    }
}

#Preview {
    DetailUIView(title:"title")
}
