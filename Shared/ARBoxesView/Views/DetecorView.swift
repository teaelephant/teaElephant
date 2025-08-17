import SwiftUI

struct DetectorView: View {
    @EnvironmentObject private var detailController: DetailManager
    @State private var showInfo = false
    
    var body: some View {
#if APPCLIP
        FullAppOffer()
#elseif !targetEnvironment(simulator)
        if let info = detailController.info {
            ZStack {
                // Background with gradient
                LinearGradient(
                    colors: [
                        Color.teaBackgroundAlt,
                        Color.teaBackgroundAlt.opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation bar with glass effect
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                detailController.info = nil
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Back to Scanner")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(Color.teaPrimaryAlt)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.glassBorder, lineWidth: 1)
                                    )
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    
                    // Enhanced show card content
                    EnhancedShowCard(info: .constant(info))
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        } else {
            Detector()
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
        }
#else
        ZStack {
            Color.teaBackgroundAlt
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "viewfinder.circle")
                    .font(.system(size: 64))
                    .foregroundColor(Color.teaPrimaryAlt.opacity(0.5))
                
                Text("AR View Not Available")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.teaTextPrimaryAlt)
                
                Text("AR features are not accessible in the simulator")
                    .font(.system(size: 16))
                    .foregroundColor(Color.teaTextSecondaryAlt)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
#endif
    }
}

struct DetectorView_Previews: PreviewProvider {
    static var previews: some View {
        DetectorView().environmentObject(DetailManager())
    }
}
