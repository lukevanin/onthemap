//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct StudentInformation {
    let objectId: String
    let uniqueKey: String
    let user: User
    let location: StudentLocation
}

//
//
//
extension StudentInformation: JSONEntity {
    init(json: Any) throws {
        guard let entity = json as? [String: Any] else {
            throw JSONError.format("dictionary")
        }
        guard let firstName = entity["firstName"] as? String else {
            throw JSONError.format("firstName")
        }
        guard let lastName = entity["lastName"] as? String else {
            throw JSONError.format("lastName")
        }
        guard let latitude = entity["latitude"] as? Double  else {
            throw JSONError.format("latitude")
        }
        guard let longitude = entity["longitude"] as? Double else {
            throw JSONError.format("longitude")
        }
        guard let objectId = entity["objectId"] as? String else {
            throw JSONError.format("objectId")
        }
        guard let uniqueKey = entity["uniqueKey"] as? String else {
            throw JSONError.format("uniqueKey")
        }
        
        let mediaURL = entity["mediaURL"] as? String
        let mapString = entity["mapString"] as? String
        
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.user = User(
            firstName: firstName,
            lastName: lastName
        )
        self.location = StudentLocation(
            mapString: mapString,
            mediaURL: mediaURL,
            longitude: longitude,
            latitude: latitude
        )
    }
}
