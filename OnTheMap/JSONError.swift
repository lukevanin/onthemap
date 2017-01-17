//
//  JSONError.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Errors which occur during parseing JSON.
//

import Foundation

enum JSONError: Error {
    
    //
    //  The data is in an unexpected format. E.g. The app expects a dictionary but the API returned an array.
    //
    case format(String)
    
    //
    //  A required field is missing, or a field is formatted incorrectly. E.g. The latitude is returned from the API as 
    //  a string, but the app expects a number.
    //
    case field(String)
}

extension JSONError: LocalizedError {
    var errorDescription: String? {
        switch self {
            
        case .format(let type):
            return "Unexpected data format. Expected \(type)."
            
        case .field(let name):
            return "Field '\(name)' is missing or invalid"
        }
    }
}
