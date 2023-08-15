//
//  AuthUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 13/08/2023.
//

import SwiftUI
import AuthenticationServices

struct AuthUIView: View {
    @ObservedObject var manager: CollectionsManager
    var body: some View {
        SignInWithAppleButton(onRequest: { request in
            request.requestedScopes = [.fullName]
        }, onCompletion: { response in
            switch response {
            case .success(let authResults):
                guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential, let code = credentials.authorizationCode, let codeString = String(data: code, encoding: .utf8) else { return }
                Task {
                    await manager.Auth(codeString)
                }
            case .failure(let error):
                print("complete error \(error.localizedDescription)")
            }
        })
    }
}

#Preview {
    AuthUIView(manager: CollectionsManager())
}
