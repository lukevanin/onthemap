//
//  UdacityAuthentication.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Concrete implementation of the UserService, using the Udacity web service API.
//

import Foundation

struct UdacityUserService: UserService {
    
    let usersURL = URL(string: "https://www.udacity.com/api/users")!
    let sessionURL = URL(string: "https://www.udacity.com/api/session")!

    //
    //  Invalidate the current authenticated session. Delete the stored cookies, and invalidates the session with the
    //  server API.
    //
    func logout(completion: @escaping UserService.LogoutCompletion) {
        var headers = [String: String]()
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                headers["X-XSRF-TOKEN"] = cookie.value
            }
        }
        HTTPService.performRequest(
            url: sessionURL,
            method: "DELETE",
            headers: headers,
            completion: { result in
                let output = result.mapToVoid()
                completion(output)
        })
    }
    
    //
    //  Log in with username and password.
    //  Call the Udacity API passing the provided username and password.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func login(username: String, password: String, completion: @escaping UserService.AuthenticationCompletion) {
        let parameters = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        login(parameters: parameters, completion: completion)
    }
    
    //
    //  Log in using facebook token. The user must have been authenticated with facebook (ie via a webview or device
    //  credentials).
    //  Call the Udacity API passing the provided facebook token.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func login(facebookToken token: String, completion: @escaping UserService.AuthenticationCompletion) {
        let parameters = [
            "facebook_mobile": [
                "access_token": token
            ]
        ]
        login(parameters: parameters, completion: completion)
    }
    
    //
    //  Perform login by posting a request to the API. Expects a Session object on response.
    //
    private func login(parameters: [String: Any], completion: @escaping UserService.AuthenticationCompletion) {
        HTTPService.performRequest(
            url: sessionURL,
            method: "POST",
            parameters: parameters,
            completion: { result in
                let output = result.map(self.trimData).map(Session.parseData)
                completion(output)
        }
        )
    }
    
    //
    //  Retrieve details for a user with given account ID. Returns a User object.
    //
    func fetchUser(accountId: String, completion: @escaping UserService.UserCompletion) {
        let url = usersURL.appendingPathComponent(accountId)
        HTTPService.performRequest(
            url: url,
            method: "GET",
            completion: { result in
                let output = result.map(self.trimData).map(User.parseData)
                completion(output)
        })
    }
    
    // MARK: Parseing
    
    //
    //  Utility function for parseing response data. Removes the first 4 characters/bytes from the response.
    //
    private func trimData(_ data: Data) -> Data {
        // Remove first 5 bytes/characters.
        let range = Range(uncheckedBounds: (5, data.count))
        let newData = data.subdata(in: range)
        return newData
    }

}
