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
	@State var view = true
	var body: some View {
		NavigationView {
			VStack {
				Spacer()
				NavigationLink(
								destination: CardViewer(),
								isActive: $view,
								label: {
									Label {
										Text("Прочитать банку")
									} icon: {
										Image(systemName: "doc").scaleEffect(x: scale, y: scale, anchor: .center)
									}.font(.title)
								})
				Spacer()
				NavigationLink(
								destination: DetectorView(),
								label: {
									Label {
										Text("Просмотреть все в AR")
									} icon: {
										Image(systemName: "square.dashed").scaleEffect(x: scale, y: scale, anchor: .center)
									}.font(.title)
								})
				Spacer()
				NavigationLink(
								destination: NewCard(),
								label: {
									Label {
										Text("Подписать банку")
									} icon: {
										Image(systemName: "pencil.tip.crop.circle.badge.plus").scaleEffect(x: scale, y: scale, anchor: .center)
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
