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

struct ARCardUIView: View {
    @EnvironmentObject private var detailController: DetailManager
    var info: TeaInfo
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                Button(action: {
                    detailController.info = info
                }, label: {
                    Text(info.data.name)
                        .font(.title)
                        .foregroundColor(.orange)
                        .buttonStyle(.automatic)
                        .padding()
                })
            }
        }
    }
}

struct ARCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ARCardUIView(info: TeaInfo(meta: TeaMeta(id:"", expirationDate: Date(), brewingTemp: 100), data: TeaData(name: "Очень вкусный чай", type: GraphQLEnum(Type_Enum.other), description: "Жень Шень А —  средне ферментированный тайваньский улун с добавлением корней женьшеня, солодки и других трав. Это улун урожая осени 2017 года. Сырье для этого чая собирают в горах Тайваня на средней высоте и обрабатывают так же, как и любой слабо ферментированный улун, но на стадии подвяливания листья чая обваливают в порошке из корней женьшеня и солодки. После этого листья скручивают и сушат при температуре 250-350 градусов. В результате снаружи гранулы чая получаются более ферментированными и темными, чем внутри.\n Жень Шень улун – не только вкусный, но и целебный чай, он сочетает в себе вкус и пользу как чайного листа, так и корней женьшеня и солодки, очень популярных в китайской медицине.\n Литера А в названии означает высшую ценовую категорию для данного вида. Также Жень Шень улун представлен в нашем магазине в категориях В и С.\n Цена на чай с одинаковым названием может отличаться в разы. На цену чая влияет регион, расположение и высота плантаций, погодные условия, влажность, способ сбора и много других факторов, которые определяют качество сырья.\n Аромат: нежный, со сладко-цветочными нотками.\n Настой: золотисто-янтарного цвета.\n Вкус: нежный, насыщенный, маслянисто-обволакивающий, с цветочными нотками и яркой шипучей сладостью, тающей на языке, как у газировки. После 3-4 пролива вкус постепенно становится более травянистым и менее женьшеневым, но сладость при этом не теряется. Можно почувствовать нотки багульника и календулы. Послевкусие яркое, долгоиграющее, сладко-женьшеневое с цитрусовой ноткой на последних проливах.\n Эффект: утоляет жажду, корень женьшеня хорошо тонизирует и бодрит, увеличивает работоспособность, улучшает память, помогает восстановить силы, побороть стресс и плохое настроение. Расщепляет жиры, налаживает работу сердечно сосудистой системы и помогает предупредить старение.  Чайный лист укрепляет зубы и десны, освежает дыхание, способствует профилактике и снятию головных болей, укрепляет сосуды, нормализует кровяное давление, очищает печень. Адсорбирует токсины и жиры, улучшает обмен веществ, чем способствует похудению.\n Корень солодки прекрасно тонизирует, чистит лимфу, укрепляет иммунитет и ускоряет пищеварение.\n Жень Шень улун не рекомендуется пить натощак, так как он сильно стимулирует обмен веществ, и если вы до этого ничего не съели, у вас может возникнуть головокружение.\n Заваривание проливом (гун фу ча): на гайвань 150 мл – столовая ложка без гоки. Выдерживает до 10 завариваний. Первые заварки лучше настаивать не более 30-40 секунд. Далее время заварки постепенно увеличивают.")))
        }
    }
}