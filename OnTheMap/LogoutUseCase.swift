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
    
    typealias Completion = (Bool) -> Void
    
    private let credentials = Credentials.shared
    
    let service: UserService
    let completion: Completion
    
    func execute() {
        
        // Clear local session.
        credentials.session = nil
        
        // Log out from facebook.
        FBSDKLoginManager().logOut()
        
        // Log out from udacity.
        service.logout() { result in
            self.completion(result.mapToSuccessBoolean())
        }
    }
}
