//
//  JSONEntity.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

protocol JSONEntity {
    init(json: Any) throws
}

extension JSONEntity {
    
    //
    //
    //
    static func parseData(_ data: Data) throws -> Self {
        // Deserialize the response and instantiate the object if possible.
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        let object = try self.init(json: json)
        return object
    }
}
