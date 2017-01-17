//
//  AuthenticationManager.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Maintains login session state and provide user details for accounts. Delegates to underlying services which perform 
//  the actual authentication.
//

import Foundation

class AuthenticationManager {
    
    typealias AuthenticationCompletion = (Result<Bool>) -> Void
    typealias SessionCompletion = (Result<Session>) -> Void

    //
    //  Current authentication state (logged in or logged out).
    //
    var isAuthenticated: Bool {
        return (credentials.session != nil)
    }
    
    private let service: UserService
    private let credentials: Credentials
    
    init(service: UserService, credentials: Credentials) {
        self.service = service
        self.credentials = credentials
    }
    
    //
    //  Retrieve the current authenticated session. Returns an error if the user has not logged in.
    //
    func fetchSession(completion: @escaping SessionCompletion) {
        if let session = credentials.session {
            completion(.success(session))
        }
        else {
            completion(.failure(ServiceError.authentication))
        }
    }
    
    //
    //  Retrieve the user details for a specific account.
    //
    func fetchUser(accountId: String, completion: @escaping UserService.UserCompletion) {
        service.fetchUser(accountId: accountId, completion: completion)
    }

    //
    //  Log out of all services. Set state to unauthenticated.
    //
    func logout(completion: @escaping AuthenticationCompletion) {
        credentials.session = nil
        service.logout() { result in
            let output = result.map { _ in false }
            completion(output)
        }
    }
    
    //
    //  Log in to service with username and password.
    //
    func login(username: String, password: String, completion: @escaping AuthenticationCompletion) {
        service.login(username: username, password: password) { [weak self] result in
            guard let `self` = self else {
                return
            }
            self.handleSession(result)
            let output = result.map { _ in return self.isAuthenticated }
            completion(output)
        }
    }
    
    //
    //  Log in to service with facebook authentication token.
    //
    func login(facebookToken token: String, completion: @escaping AuthenticationCompletion) {
        service.login(facebookToken: token) { [weak self] result in
            guard let `self` = self else {
                return
            }
            self.handleSession(result)
            let output = result.map { _ in return self.isAuthenticated }
            completion(output)
        }
    }

    //
    //  Process response from authentication service. Update internal state according to success of response.
    //
    private func handleSession(_ result: Result<Session>) {
        switch result {
        case .success(let session):
            credentials.session = session
        case .failure(_):
            credentials.session = nil
        }
    }

}
