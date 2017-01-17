//
//  StudentRequest.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Encapsulate data for adding and updating student information.
//

import Foundation

struct StudentRequest {
    let uniqueKey: String
    let user: User
    let location: StudentLocation
}

//
//  Extension for serializing the student request to a JSON compatible structure.
//
extension StudentRequest {
    func toJSON() -> [String: Any] {
        var output = [String: Any]()
        output["uniqueKey"] = uniqueKey
        output["firstName"] = user.firstName
        output["lastName"] = user.lastName
        output["latitude"] = location.latitude
        output["longitude"] = location.longitude
        
        if let mapString = location.mapString {
            output["mapString"] = mapString
        }
        
        if let mediaURL = location.mediaURL {
            output["mediaURL"] = mediaURL;
        }
        
        return output
    }
}
