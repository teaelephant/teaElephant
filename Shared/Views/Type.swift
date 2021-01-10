//
//  Type.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10.01.2021.
//

import SwiftUI

struct Type: View {
    var type: TeaType
    var body: some View {
        Text(type.rawValue).italic().multilineTextAlignment(.trailing)
    }
}

struct Type_Previews: PreviewProvider {
    static var previews: some View {
        Type(type: TeaType.tea)
    }
}
