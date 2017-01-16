//
//  ServiceError.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    
    // Error with authentication (invalid username / password / token). 403.
    case authentication
    
    // Server error (500)
    case server
    
    // Network connection error.
    case network
    
    // Invalid or unsupported content.
    case content
    
    // Invalid request.
    case request
}
