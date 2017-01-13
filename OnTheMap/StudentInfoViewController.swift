//
//  WebsiteViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MapKit

class StudentInfoViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: Actions
    
    //
    //  Dismiss the modal without saving the student information.
    //
    @IBAction func onCancelButtonAction(_ sender: Any) {
        // TODO: Implement
    }
    
    //
    //  Called when user taps submit button. Compose student information and send to web service. 
    //  If the web service call fails, then show an error message. 
    //  If the web service call succeeds, then show a success message, dismiss the view controller, and show the new 
    //  location on the map.
    //
    @IBAction func onSubmitButtonAction(_ sender: Any) {
        // TODO: Implement
    }
}
