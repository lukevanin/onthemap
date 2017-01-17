//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Information relating to the map location added by the student, including coordinates and optionally a media URL.
//

import Foundation

struct StudentLocation {

    //
    //  Optional URL entry. Note: This may contain junk text, an invalid URL, or be absent entirely.
    //
    let mediaURL: String?

    //
    //  Text description of the location coordinate (e.g. New York).
    //
    let mapString: String?
    
    // 
    //  Longitude of the location.
    //
    let longitude: Double
    
    //
    //  Latitude of the location.
    //
    let latitude: Double
}

//
// Extension for providing a valid URL from the underlying data.
//
extension StudentLocation {
    
    //
    //  Returns true if the entry has a valid URL.
    //
    var hasValidURL: Bool {
        return (validURL != nil)
    }
    
    //
    //  Attempt to parse the underlying media URL into a valid HTTP URL. This only performs rudimentary validation to 
    //  assert that the basic components are intact, bust does not ensure that the URL is actually accessible. 
    //
    //  Inserts the "http" scheme if the URL does not already have a valid scheme, to prevent Safari from crashing.
    //
    var validURL: URL? {
        
        guard let mediaURL = mediaURL, var components = URLComponents(string: mediaURL) else {
            return nil
        }
        
        if components.scheme == nil {
            // Address is a valid URL, but is missing the scheme part, which will cause Safari view controller to crash.
            // Try fix it by using HTTP scheme
            components.scheme = "http"
        }
        
        return components.url
    }
}
