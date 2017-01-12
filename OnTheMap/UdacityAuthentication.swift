//
//  UdacityAuthentication.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class UdacityAuthentication: Authentication {

    var isAuthenticated: Bool = false
    
    //
    //  Invalidate the current authenticated session.
    //
    func logout() {
        isAuthenticated = false
        // FIXME: Invalidate facebook login
    }
    
    //
    //  Log in with username and password.
    //  Call the Udacity API passing the provided username and password.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func login(username: String, password: String, completion: (AuthenticationResponse) -> Void) {
    
    }
    
    //
    //  Log in using facebook token. The user must have been authenticated with facebook (ie via a webview or device
    //  credentials).
    //  Call the Udacity API passing the provided facebook token.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func loginWithFacebook(token: Data, completion: (AuthenticationResponse) -> Void) {
    
    }
}
