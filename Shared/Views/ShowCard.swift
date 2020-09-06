//
//  ShowCard.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import SwiftUI

struct ShowCard: View {
    @Binding var info: TeaInfo?
    @ViewBuilder
    var body: some View {
        if info != nil {
            VStack(alignment:.leading) {
                Text(info!.data.name).bold().font(.title).foregroundColor(.orange)
                HStack{
                    Text(info!.data.type.rawValue).italic().multilineTextAlignment(.trailing)
                    Spacer()
                }
                Spacer()
                Text(info!.data.description).baselineOffset(5)
                Spacer()
                HStack {
                    Text("Годен до:")
                    Text(self.dateToString(info!.meta.expirationDate)).foregroundColor(.red)
                }
                HStack {
                    Text("Температура заваривания")
                    Text(info!.meta.brewingTemp.formattedString)
                }
            }.padding(.horizontal, 20)
        } else {
            Text("Считайте метку").bold().font(.title)
        }
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from:date)
    }
}

struct ShowCard_Previews: PreviewProvider {
    static var previews: some View {
        ShowCard(info: .constant(TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: TeaType.other, description: "тут длинная история о том как отважные первопроходцы нашли первые листочки этого прекрасного чая, и отбиваясь от нападения туземцев смогли доставить драгоценные листочки этого чая свой королеве"))))
    }
}

struct ShowCard_Previews2: PreviewProvider {
    static var previews: some View {
        ShowCard(info: .constant(nil))
    }
}

extension Formatter {
    static let stringFormatters: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
}

extension Int {
    var formattedString: String {
        return Formatter.stringFormatters.string(for: self) ?? ""
    }
}
