//
//  Name.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10.01.2021.
//

import SwiftUI

struct Name: View {
    var name: String
    var body: some View {
        Text(name).bold().font(.title).foregroundColor(.orange)
        
    }
}

struct Name_Previews: PreviewProvider {
    static var previews: some View {
        Name(name: "Дян хун")
    }
}
