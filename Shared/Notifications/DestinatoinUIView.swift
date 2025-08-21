//
//  DestinatoinUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 29/08/2023.
//

import SwiftUI

struct DestinatoinUIView: View {
    var id : String
    var message: String
    @StateObject private var manager = Reader(infoReader: NFCReader(), extender: RecordGetter())
    var body: some View {
        if manager.detectedInfo == nil {
            ProgressView().onAppear{
                Task{
                    await manager.processQRCode(id)
                }
            }
        } else {
            ShowCard(info: $manager.detectedInfo)
        }
    }
}

#Preview {
    DestinatoinUIView(id: "", message: "some message")
}
