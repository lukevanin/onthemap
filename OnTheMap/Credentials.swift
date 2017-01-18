//
//  Credentials.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Shared object for storing login credentials after the user is authenticated. Used by the authentication manager, 
//  although it can be accessed anywhere in the app if needed.
//

import Foundation

class Credentials {
    
    //
    //  Singleton instance.
    //
    static let shared = Credentials()
    
    //
    //  True if a valid session exists.
    //
    var isAuthenticated: Bool {
        return session != nil
    }
    
    //
    //  Data for the current authenticated session. This is set on login, and nullified on logout.
    //
    var session: Session?
}
