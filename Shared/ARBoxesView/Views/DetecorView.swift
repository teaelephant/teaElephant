import SwiftUI

struct DetectorView: View {
    var body: some View {
        #if APPCLIP
        FullAppOffer()
        #elseif !targetEnvironment(simulator)
            Detector().edgesIgnoringSafeArea(.all)
        #else
            Text("AR View not accessible in simulator")
        #endif
    }
}

struct DetectorView_Previews: PreviewProvider {
    static var previews: some View {
        DetectorView()
    }
}
