//
//  TitleUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 10/08/2023.
//

import Foundation
import SwiftUI
import ApolloAPI
import TeaElephantSchema

@available(iOS 17.0, *)
struct ARCardUIView: View {
    @EnvironmentObject private var detailController: DetailManager
    var info: TeaInfo
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Button(action: {
                    detailController.info = info
                }, label: {
                    VStack {
                        let textColor: Color = {
                            switch info.data.type {
                            case .tea:
                                return .orange
                            case .coffee:
                                return .blue
                            case .herb:
                                return .green
                            default:
                                return .gray
                            }
                        }()
                        Text(info.data.name)
                            .font(.title)
                            .foregroundColor(textColor)
                            .buttonStyle(.automatic)
                            .padding()
                        HStack{
                            ForEach(info.tags, id: \.self.id) { tag in
                                let color = Color(hex: tag.color)
                                Circle()
                                    .stroke(color.isDark() ? .white : .black, lineWidth: 1)
                                    .fill(color)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                })
            }
        }
    }
}


@available(iOS 17.0, *)
struct ARCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.tea), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}

@available(iOS 17.0, *)
struct ARCard_Herb: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.herb), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}

@available(iOS 17.0, *)
struct ARCard_Coffee: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.coffee), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}

@available(iOS 17.0, *)
struct ARCard_Other: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.other), description: ""), tags: [Tag(id: "1", name: "1", color: "#BE000000", category: ""),Tag(id: "2", name: "2", color: "#FFFFFFFF", category: ""),Tag(id: "3", name: "3", color: "#ABFF024F", category: "")]))
        }
    }
}
