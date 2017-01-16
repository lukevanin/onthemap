//
//  JSONError.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

enum JSONError: Error {
    case format(String)
    case field(String)
}
