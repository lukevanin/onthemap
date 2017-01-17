//
//  NativeLocationService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Location service providing reverse geocoding using the native OS CoreLocation framework.
//

import Foundation
import CoreLocation

enum LocationError: Swift.Error {
    
    // Another geo location request is already executing.
    case busy
}

//
extension LocationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .busy:
            return "Cannot perform geo location request while another request is in progress. Wait for the other request to finish then try again."
        }
    }
}

struct NativeLocationService: LocationService {
    
    private let geocoder = CLGeocoder()
    
    //
    //  Stop any geocoding operation which is currently in progress.
    //
    func cancelAddressLookup() {
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
    }
    
    //
    //  Obtain geocoded location coordinates from a given address string. Only one geocoding operation may execute at
    //  a time. It is an error to try to execute more than one geocoding operation concurrently.
    //
    func lookupAddress(_ address: String, completion: @escaping LocationLookupCompletion) {
        guard !geocoder.isGeocoding else {
            completion(Result.failure(LocationError.busy))
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
