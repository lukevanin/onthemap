//
//  LogoutUseCase.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Encapsulates logic for logging out.
//

import Foundation
import FBSDKLoginKit

struct LogoutUseCase {
    
    typealias Completion = () -> Void
    
    let authentication: AuthenticationManager
    let completion: Completion
    
    func execute() {
        // Log out from facebook.
        FBSDKLoginManager().logOut()
        
        // Log out from udacity.
        authentication.logout() { _ in
            self.completion()
        }
    }
}
