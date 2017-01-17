//
//  Session.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  User authentication session data, namely the session ID and account ID.
//

import Foundation

struct Session {
    
    //
    //  Unique token for the auth session. Each login creates a new token.
    //
    let sessionId: String
    
    //
    //  Persistent ID associated with the user's account. Immutable between logins.
    //
    let accountId: String
}

//
//  Extension for instantiating session from JSON. Most of the available session information is ignored by the app.
//
extension Session: JSONEntity {
    init(json: Any) throws {
        guard let entity = json as? Dictionary<String, Any> else {
            throw JSONError.format("dictionary")
        }
        guard let session = entity["session"] as? Dictionary<String, Any> else {
            throw JSONError.field("session")
        }
        guard let account = entity["account"] as? Dictionary<String, Any> else {
            throw JSONError.field("account")
        }
        guard let sessionId = session["id"] as? String else {
            throw JSONError.field("session.id")
        }
        guard let accountId = account["key"] as? String else {
            throw JSONError.field("account.key")
        }
        self.sessionId = sessionId
        self.accountId = accountId
    }
}
