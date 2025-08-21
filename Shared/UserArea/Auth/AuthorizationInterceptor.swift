//
//  AuthorizationInterceptor.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 14/08/2023.
//

import Foundation
import Apollo
import ApolloAPI
import KeychainSwift

let tokenKey = "BearerToken"

class AuthorizationInterceptor: ApolloInterceptor {
    var id =  "AuthorizationInterceptor"
    
    
    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation : GraphQLOperation {
        let keychain = KeychainSwift()
        keychain.synchronizable = true  // Match the synchronizable setting used in AuthManager
        if let token = keychain.get(tokenKey) {
            let value = "Bearer \(token)"
            // Do not log tokens in production; header is set without printing
            request.addHeader(name: "Authorization", value: value)
        }
        
        chain.proceedAsync(request: request,
                            response: response,
                           interceptor: self,
                            completion: completion)
    }
    
}
