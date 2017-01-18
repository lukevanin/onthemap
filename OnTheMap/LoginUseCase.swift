//
//  UserLoginUseCase.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Use case for logging in a user with either a username and password, or facebook token. If authentication is 
//  successful then the current session is stored.
//

import Foundation

struct LoginUseCase {
    
    typealias Completion = (Result<Bool>) -> Void
    
    enum Request {
        case credentials(username: String, password: String)
        case facebook(token: String)
    }

    private let credentials = Credentials.shared

    let request: Request
    let service: UserService
    let completion: Completion
    
    func execute() {
        switch request {
            
        case .credentials(username: let username, password: let password):
            // Login with username and password.
            service.login(username: username, password: password, completion: handleLoginResult)
            
        case .facebook(token: let token):
            // Login with facebook token acquired externally through Facebook auth flow.
            service.login(facebookToken: token, completion: handleLoginResult)
        }
    }
    
    private func handleLoginResult(_ result: Result<Session>) {
        
        switch result {
            
        case .success(let session):
            // Login successful. Save the session information.
            self.credentials.session = session
            
        case .failure(_):
            // Login failed. Remove the current login session.
            self.credentials.session = nil
            
        }
        
        // Convert the response to a simple boolean (the app does not need to know about the session).
        let output = result.map { _ in
            return self.credentials.isAuthenticated
        }
        
        self.completion(output)
    }
}
