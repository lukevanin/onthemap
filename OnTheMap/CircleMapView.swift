//
//  CircleMapView.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
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
