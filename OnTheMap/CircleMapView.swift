//
//  CircleMapView.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Display a map view with a circular cutout mask. Used on step 2 of 2 on the "Add your location" screen flow. Serves 
//  no purpose other than aesthetics.
//

import Foundation
import MapKit

class CircleMapView: MKMapView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.size
        let radius = min(size.width, size.height) * 0.5
        layer.cornerRadius = radius
    }
}
