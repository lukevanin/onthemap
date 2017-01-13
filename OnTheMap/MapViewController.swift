//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, StudentsController {
    
    var model: [StudentInformation]?
    var delegate: StudentsControllerDelegate?
    var viewController: UIViewController {
        return self
    }
    
    // MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    
    @IBAction func onLogoutAction(_ sender: Any) {
        delegate?.studentsController(controller: self, action: .logout, sender: sender)
    }
    
    @IBAction func onPinAction(_ sender: Any) {
        delegate?.studentsController(controller: self, action: .addLocation, sender: sender)
    }
    
    @IBAction func onRefreshAction(_ sender: Any) {
        delegate?.studentsController(controller: self, action: .refresh, sender: sender)
    }

    // MARK: View controller life cycle
    
}
