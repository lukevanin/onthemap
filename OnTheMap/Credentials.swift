//
//  Credentials.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class Credentials {
    
    typealias SessionCompletion = (Session?, Error?) -> Void
    
    static let shared = Credentials()
    
    var session: Session?
    
}
