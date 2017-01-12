//
//  MockAuthentication.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Provides predefined response to authentication requests. Used to test components (ie UI) which use an authenticator.
//  Returns "authenticated" by default.
//

import Foundation

class MockAuthentication: Authentication {

    var expectedResponse: AuthenticationResponse
    var isAuthenticated: Bool = false
    
    convenience init() {
        self.init(response: .authenticated)
    }
    
    required init(response: AuthenticationResponse) {
        self.expectedResponse = response
    }
    
    func logout() {
        isAuthenticated = false
    }

    func login(username: String, password: String, completion: AuthenticationCompletion) {
        complete(completion)
    }

    func loginWithFacebook(token: Data, completion: AuthenticationCompletion) {
        complete(completion)
    }
    
    func complete(_ completion: AuthenticationCompletion) {
        switch expectedResponse {
        case .authenticated:
            isAuthenticated = true
        case .error(_):
            break
        }
        completion(expectedResponse)
    }
}
