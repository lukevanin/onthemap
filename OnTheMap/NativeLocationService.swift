//
//  NativeLocationService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation

struct NativeLocationService: LocationService {
    
    enum Error: Swift.Error {
        
        // Another geo location request is already executing.
        case busy
    }
    
    private let geocoder = CLGeocoder()
    
    //
    //
    //
    func cancelAddressLookup() {
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
    }
    
    //
    //
    //
    func lookupAddress(_ address: String, completion: @escaping LocationLookupCompletion) {
        guard !geocoder.isGeocoding else {
            completion(Result.failure(Error.busy))
            return
        }
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                completion(Result.success(placemarks))
            }
            else if let error = error {
                completion(Result.failure(error))
            }
            else {
                completion(Result.failure(ServiceError.server))
            }
        }
    }
}
