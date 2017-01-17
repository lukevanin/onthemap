//
//  Authentication.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Abstraction of a user service, which provides features for authentication, and accessing user related information.
//

import Foundation

protocol UserService {

    typealias AuthenticationCompletion = (Result<Session>) -> Void
    typealias UserCompletion = (Result<User>) -> Void
    typealias LogoutCompletion = (Result<Void>) -> Void

    //
    //  Invalidate the current authenticated session.
    //
    func logout(completion: @escaping LogoutCompletion)
    
    //
    //  Log in with username and password.
    //  Call the Udacity API passing the provided username and password. 
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to 
    //  unauthenticated and show an error.
    //
    func login(username: String, password: String, completion: @escaping AuthenticationCompletion)
    
    //
    //  Log in using facebook token. The user must have been authenticated with facebook (ie via a webview or device
    //  credentials).
    //  Call the Udacity API passing the provided facebook token.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func login(facebookToken: String, completion: @escaping AuthenticationCompletion)
    
    //
    //  Retrieve user information for a given account ID.
    //
    func fetchUser(accountId: String, completion: @escaping UserCompletion)
}
