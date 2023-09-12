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
        if let token = AuthManager.shared.keychain.get(tokenKey) {
            print(token)
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }
        
        chain.proceedAsync(request: request,
                            response: response,
                           interceptor: self,
                            completion: completion)
    }
    
}
