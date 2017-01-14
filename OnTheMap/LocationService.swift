//
//  LocationService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation

typealias LocationLookupCompletion = (Result<[CLPlacemark]>) -> Void

protocol LocationService {
    
    //
    //
    //
    func cancelAddressLookup()
    
    //
    //
    //
    func lookupAddress(_ address: String, completion: @escaping LocationLookupCompletion)
}
