//
//  Type.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10.01.2021.
//

import SwiftUI
import TeaElephantSchema

struct TypeView: View {
    var type: Type_Enum
    var body: some View {
        Text(type.rawValue).italic().multilineTextAlignment(.trailing)
    }
}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        TypeView(type: Type_Enum.tea)
    }
}
