import Foundation
import Apollo
import KeychainSwift

let tokenKey = "BearerToken"

struct AuthorizationInterceptor: HTTPInterceptor {
    private let tokenProvider: @Sendable () -> String?

    init(tokenProvider: @escaping @Sendable () -> String? = {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        return keychain.get(tokenKey)
    }) {
        self.tokenProvider = tokenProvider
    }

    func intercept(request: URLRequest, next: NextHTTPInterceptorFunction) async throws -> HTTPResponse {
        var request = request
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return try await next(request)
    }
}
