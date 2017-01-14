//
//  MockLocationService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation

class MockLocationService: LocationService {
    
    private let placemarks: Result<[CLPlacemark]>
    
    init(placemarks: Result<[CLPlacemark]>, error: Error?) {
        self.placemarks = placemarks
    }
    
    func cancelAddressLookup() {
        
    }
    
    func lookupAddress(_ address: String, completion: @escaping LocationLookupCompletion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion(self.placemarks)
        }
    }
}
