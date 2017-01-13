//
//  AuthenticationManager.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class AuthenticationManager {

    //
    //  Current authentication state (logged in or logged out).
    //
    var isAuthenticated: Bool = false

    private let service: Authentication
    
    init(service: Authentication) {
        self.service = service
    }
    
    //
    //  Log out of all services. Set state to unauthenticated.
    //
    func logout() {
        self.service.logout()
        isAuthenticated = false
    }
    
    //
    //  Log in to service with username and password.
    //
    func login(username: String, password: String, completion: @escaping AuthenticationCompletion) {
        service.login(username: username, password: password) { [weak self] response in
            self?.handleResponse(response)
            completion(response)
        }
    }
    
    //
    //  Log in to service with facebook authentication token.
    //
    func loginWithFacebook(token: Data, completion: @escaping AuthenticationCompletion) {
        service.loginWithFacebook(token: token) { [weak self] response in
            self?.handleResponse(response)
            completion(response)
        }
    }
    
    //
    //  Process response from authentication service. Update internal state according to success of response.
    //
    private func handleResponse(_ response: AuthenticationResponse) {
        switch response {
        case .authenticated:
            isAuthenticated = true
        default:
            isAuthenticated = false
        }
    }

}
