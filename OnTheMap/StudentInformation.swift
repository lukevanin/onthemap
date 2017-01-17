//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Record containing the name, location, and media URL for a student.
//

import Foundation

struct StudentInformation {
    
    //
    //  Unique identifier of the object. Assigned by the web service API when the object is added. The object may be 
    //  updated by passing this objectId when making an update request to the API.
    //
    let objectId: String
    
    //
    //  Key assigned by the app when the object is added to the API. Recommended to be set to the users' account ID 
    //  although this is not actually necessarily unique and can contain any value.
    //
    let uniqueKey: String
    
    //
    //  Information specific to the user, e.g. the user's name.
    //
    let user: User
    
    //
    //  Information pertaining to the map location, e.g. coordinates and URL.
    //
    let location: StudentLocation
}

//
//  Extension on StudentInformation for creating instances from JSON data. Most of the fields are required, and an 
//  exception will be thrown if the field is missing, or not in the expected format. Entities with missing or invalid 
//  fields are excluded from the results. 
//
//  Some fields are optional (e.g. mediaURL) and will resolve to nil values. The entity will still be included in the 
//  results but without the optional information.
//
extension StudentInformation: JSONEntity {
    init(json: Any) throws {
        
        // Parse required values.
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
        
        // Optional values.
        let mediaURL = entity["mediaURL"] as? String
        let mapString = entity["mapString"] as? String
        
        // Instantiate objects.
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.user = User(
            firstName: firstName,
            lastName: lastName
        )
        self.location = StudentLocation(
            mediaURL: mediaURL,
            mapString: mapString,
            longitude: longitude,
            latitude: latitude
        )
    }
}
