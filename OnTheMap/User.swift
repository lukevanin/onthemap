//
//  User.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct User {
    let firstName: String
    let lastName: String
}

extension User: JSONEntity {
    init(json: Any) throws {
        guard let entity = json as? Dictionary<String, Any> else {
            throw JSONError.format("dictionary")
        }
        guard let firstName = entity["first_name"] as? String else {
            throw JSONError.field("first_name")
        }
        guard let lastName = entity["last_name"] as? String else {
            throw JSONError.field("last_name")
        }
        self.firstName = firstName
        self.lastName = lastName
    }
}
