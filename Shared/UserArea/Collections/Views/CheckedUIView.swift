//
//  CheckedUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 17/09/2023.
//

import SwiftUI

struct CheckedUIView: View {
    var body: some View {
        Image(systemName: "checkmark")
            .resizable()
            .padding(20)
            .foregroundColor(.green)
    }
}

#Preview {
    CheckedUIView()
}
