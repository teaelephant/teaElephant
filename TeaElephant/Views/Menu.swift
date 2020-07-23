//
//  Menu.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import SwiftUI

struct Menu: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                NavigationLink(
                    destination: NewCard(),
                    label: {
                        Label{ Text("Подписать банку") } icon: {
                            Image(systemName: "pencil.tip.crop.circle.badge.plus").scaleEffect(x: 2, y: 2, anchor: .center)
                        }.font(.title)
                    })
                Spacer()
                NavigationLink(
                    destination: CardViewer(),
                    label: {
                       Label{ Text("Прочитать банку") } icon: {
                           Image(systemName: "doc").scaleEffect(x: 2, y: 2, anchor: .center)
                       }.font(.title)
                })
                Spacer()
            }.navigationBarTitle("Меню")
        }
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
