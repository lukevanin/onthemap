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

class MockUserService: UserService {

    var session: Result<Session>
    var user: Result<User>
    
    convenience init() {
        let session = Session(
            sessionId: "0000000000000000000000000000000000000000000",
            accountId: "996618664"
        )
        let user = User(
            firstName: "Jarrod",
            lastName: "Parkes"
        )
        self.init(session: .success(session), user: .success(user), error: nil)
    }
    
    required init(session: Result<Session>, user: Result<User>, error: ServiceError?) {
        self.session = session
        self.user = user
    }
    
    func logout() {
    }

    func login(username: String, password: String, completion: @escaping AuthenticationCompletion) {
        completeLogin(completion)
    }

    func login(facebookToken: String, completion: @escaping AuthenticationCompletion) {
        completeLogin(completion)
    }
    
    func completeLogin(_ completion: @escaping AuthenticationCompletion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else {
                return
            }
            completion(self.session)
        }
    }
    
    func fetchUser(accountId: String, completion: @escaping UserCompletion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else {
                return
            }
            completion(self.user)
        }
    }
}
