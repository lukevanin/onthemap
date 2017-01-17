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
    
    //
    // Invalid or unsupported content returned by the server_
    //
    case response
    
    //
    // Invalid request sent by app (e.g. invalid data, incorrect URL).
    //
    case request
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .authentication:
            return "Cannot log in. Please check your credentials and try again."
            
        case .server:
            return "The server could not perform the requested action. Please try again in a few minutes."
            
        case .network:
            return "There was a problem with the network connection. Please check your connection and try again."
            
        case .response:
            return "The server returned an unexpected response. Please check that you are using the latest version of the app."
            
        case .request:
            return "The app sent a request which was not recognized by the server. Please check that you are using the latest version of the app."
        }
    }
}
