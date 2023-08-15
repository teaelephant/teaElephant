import SwiftUI

struct DetectorView: View {
    @EnvironmentObject private var detailController: DetailManager
    var body: some View {
        #if APPCLIP
        FullAppOffer()
        #elseif !targetEnvironment(simulator)
        if let info = detailController.info {
            VStack{
                Button(action: {
                    detailController.info = nil
                }) {
                    Text("Back")
                }
            }
            ShowCard(info:.constant(info))
        } else {
            Detector().edgesIgnoringSafeArea(.all)
        }
        #else
            Text("AR View not accessible in simulator")
        #endif
    }
}

struct DetectorView_Previews: PreviewProvider {
    static var previews: some View {
        DetectorView().environmentObject(DetailManager())
    }
}
