//
//  Authentication.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

enum AuthenticationError: Error {
    case credentials
    case network
}

enum AuthenticationResponse {
    case error(AuthenticationError)
    case authenticated
}

typealias AuthenticationCompletion = (AuthenticationResponse) -> Void

protocol Authentication {
    
    //
    //  Current authentication state (logged in or logged out).
    //
    var isAuthenticated: Bool {
        get
    }
    
    //
    //  Invalidate the current authenticated session.
    //
    func logout()
    
    //
    //  Log in with username and password.
    //  Call the Udacity API passing the provided username and password. 
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to 
    //  unauthenticated and show an error.
    //
    func login(username: String, password: String, completion: AuthenticationCompletion)
    
    //
    //  Log in using facebook token. The user must have been authenticated with facebook (ie via a webview or device
    //  credentials).
    //  Call the Udacity API passing the provided facebook token.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func loginWithFacebook(token: Data, completion: AuthenticationCompletion)
}
