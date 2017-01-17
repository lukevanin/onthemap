//
//  User.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Information specific to the user, e.g. name and surname.
//

import Foundation

struct User {
    let firstName: String
    let lastName: String
}

//
//  Extension for serializing a user to JSON compatible data.
//
extension User: JSONEntity {
    init(json: Any) throws {
        guard let entity = json as? [String: Any] else {
            throw JSONError.format("dictionary")
        }
        guard let user = entity["user"] as? [String: Any] else {
            throw JSONError.field("user")
        }
        guard let firstName = user["first_name"] as? String else {
            throw JSONError.field("user.first_name")
        }
        guard let lastName = user["last_name"] as? String else {
            throw JSONError.field("user.last_name")
        }
        self.firstName = firstName
        self.lastName = lastName
    }
}
