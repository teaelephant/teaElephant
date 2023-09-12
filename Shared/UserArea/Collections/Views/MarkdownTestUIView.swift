//
//  MarkdownTestUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 15/12/2023.
//

import SwiftUI

struct MarkdownTestUIView: View {
    private var value = "Hello, **World**!"
    var body: some View {
        Text(value)
    }
}

#Preview {
    MarkdownTestUIView()
}
