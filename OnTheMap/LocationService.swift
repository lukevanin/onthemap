//
//  LocationService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Abstraction of location service which provides features for obtaining geolocation coordinates (latitude and 
//  longitude) given a human readable address string.
//

import Foundation
import CoreLocation

typealias LocationLookupCompletion = (Result<[CLPlacemark]>) -> Void

protocol LocationService {
    
    //
    //  Stop any currently executing lookup operations.
    //
    func cancelAddressLookup()
    
    //
    //  Lookup coordinates for an address.
    //
    func lookupAddress(_ address: String, completion: @escaping LocationLookupCompletion)
}
