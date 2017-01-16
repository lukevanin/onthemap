//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct StudentLocation {
    let mapString: String?
    let mediaURL: String?
    let longitude: Double
    let latitude: Double
}

//
//
//
extension StudentLocation {
    
    //
    //
    //
    var hasValidURL: Bool {
        return (validURL != nil)
    }
    
    //
    //
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
