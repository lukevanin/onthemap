//
//  LocationLookupViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class LocationLookupViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findButton: UIButton!
    
    // MARK: Actions
    
    //
    //
    //
    @IBAction func onFindButtonAction(_ sender: Any) {
        // TODO: Show activity indicator while geocoding the input address.
    }
    
    @IBAction func onCancelButtonAction(_ sender: Any) {
        // TODO: Dismiss the current modal view without saving the student information.
    }
}
