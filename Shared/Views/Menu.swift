//
//  Menu.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import SwiftUI

let scale: CGFloat = 1.5

struct Menu: View {
    @State var isNewCardActive = true
    var body: some View {
        NavigationView{
            VStack {
                if #available(iOS 17.0, *) {
                    HStack{
                        Spacer()
                        NavigationLink(
                            destination: UserAreaUIView(),
                            label: {
                                Label {
                                    Text("")
                                } icon: {
                                    Image(systemName: "person.circle").scaleEffect(x: scale, y: scale, anchor: .center)
                                }.font(.title)
                            }).padding(.horizontal)
                    }
                }
                Spacer()
                NavigationLink(
                    destination: CardViewer(),
                    label: {
                        Label {
                            Text("Read info from tea tin")
                        } icon: {
                            Image(systemName: "doc").scaleEffect(x: scale, y: scale, anchor: .center)
                        }.font(.title)
                    })
                Spacer()
                NavigationLink(
                    destination: DetectorView().environmentObject(DetailManager()),
                    label: {
                        Label {
                            Text("View all in AR")
                        } icon: {
                            Image(systemName: "square.dashed").scaleEffect(x: scale, y: scale, anchor: .center)
                        }.font(.title)
                    })
                Spacer()
                NavigationLink(
                    destination: NewCard(),
                    label: {
                        Label {
                            Text("Write info to tea tin")
                        } icon: {
                            Image(systemName: "pencil.tip.crop.circle.badge.plus").scaleEffect(x: scale, y: scale, anchor: .center)
                        }.font(.title)
                    })
                Spacer()
            }.navigationBarTitle("Menu")
        }
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
