//
//  UdacityAuthentication.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct UdacityUserService: UserService {
    
    let sessionURL = URL(string: "https://www.udacity.com/api/session")!
    let usersURL = URL(string: "https://www.udacity.com/api/users")!

    //
    //  Invalidate the current authenticated session.
    //
    func logout() {
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
            headers: headers
        )
    }
    
    //
    //  Log in with username and password.
    //  Call the Udacity API passing the provided username and password.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func login(username: String, password: String, completion: @escaping AuthenticationCompletion) {
        let json = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        HTTPService.performRequest(
            url: sessionURL,
            method: "POST",
            parameters: json,
            completion: { result in
                let output = self.parseSession(result: result)
                completion(output)
            }
        )
    }
    
    //
    //  Log in using facebook token. The user must have been authenticated with facebook (ie via a webview or device
    //  credentials).
    //  Call the Udacity API passing the provided facebook token.
    //  If the response indicates a valid login then set the state to authenticated, otherwise set the state to
    //  unauthenticated and show an error.
    //
    func login(facebookToken token: String, completion: @escaping AuthenticationCompletion) {
        let json = [
            "facebook_mobile": [
                "access_token": token
            ]
        ]
        HTTPService.performRequest(
            url: sessionURL,
            method: "POST",
            parameters: json,
            completion: { result in
                let output = self.parseSession(result: result)
                completion(output)
            }
        )
    }
    
    //
    //
    //
    func fetchUser(accountId: String, completion: @escaping UserCompletion) {
        let url = usersURL.appendingPathComponent(accountId)
        HTTPService.performRequest(
            url: url,
            method: "GET",
            completion: { result in
                let output = self.parseUser(result: result)
                completion(output)
        })
    }
    
    // MARK: Parseing
    
    //
    //
    //
    private func parseSession(result: Result<Data>) -> Result<Session> {
        return result.map(self.trimData).map(Session.parseData)
    }
    
    //
    //
    //
    private func parseUser(result: Result<Data>) -> Result<User> {
        return result.map(self.trimData).map(User.parseData)
    }
    
    //
    //
    //
    private func trimData(_ data: Data) -> Data {
        // Remove first 5 bytes/characters.
        let range = Range(uncheckedBounds: (5, data.count))
        let newData = data.subdata(in: range)
        return newData
    }

}
