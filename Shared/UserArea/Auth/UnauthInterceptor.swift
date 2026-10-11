import Apollo
import ApolloAPI

struct UnauthInterceptor: GraphQLInterceptor {
    private func isUnauthenticated(_ error: GraphQLError) -> Bool {
        if let code = error.extensions?["code"] as? Int, code == -1 {
            return true
        }
        if let code = error.extensions?["code"] as? String {
            if Int(code) == -1 || code.lowercased().contains("unauth") {
                return true
            }
        }
        return (error.message ?? "").lowercased().contains("unauth")
    }

    func intercept<Request: GraphQLRequest>(
        request: Request,
        next: NextInterceptorFunction<Request>
    ) async throws -> InterceptorResultStream<Request> {
        await next(request).map { response in
            guard response.result.source == .server else { return response }
            await MainActor.run {
                guard let error = response.result.errors?.first else {
                    AuthManager.shared.auth = true
                    return
                }
                if isUnauthenticated(error) {
                    AuthManager.shared.keychain.synchronizable = true
                    AuthManager.shared.keychain.delete(tokenKey)
                    AuthManager.shared.auth = false
                }
            }
            return response
        }
    }
}
