//
//  LocationLookupViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Screen 1 of 2 for adding a location.
//
//  Allows the user to look up geo location coordinates from a text address.
//

import UIKit
import MapKit

class LocationLookupViewController: UIViewController {
    
    enum State {
        case pending
        case busy
    }
    
    private let locationService = NativeLocationService()
    
    private let dismissSegue = "dismiss"
    private let infoSegue = "info"
    
    private var state: State = .pending {
        didSet {
            updateState()
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findButton: UIButton!
    
    // MARK: Actions
    
    //
    //  "Find on map" tapped. Dismiss the keyboard and geocode the address.
    //
    @IBAction func onFindButtonAction(_ sender: Any) {
        locationTextField.resignFirstResponder()
        state = .busy
        performLookup()
    }

    //
    //  Cancel button tapped. Dismiss the modal and return to the presenting view controller.
    //
    @IBAction func onCancelButtonAction(_ sender: Any) {
        performSegue(withIdentifier: dismissSegue, sender: sender)
    }
    
    // MARK: View controller life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }
    
    // MARK: State management
    
    //
    //  Update the UI to display the current state. Disables UI input and shows activity indicator while geocoding is in
    //  progress
    //
    private func updateState() {
        switch state {
        
        case .pending:
            configureUI(inputEnabled: true, activityVisible: false)
            
        case .busy:
            configureUI(inputEnabled: false, activityVisible: true)
        }
    }
    
    //
    //  Configure UI. Disable/enable textfield and button input. Show/hide activity indicator.
    //
    private func configureUI(inputEnabled: Bool, activityVisible: Bool) {
        locationTextField.isEnabled = inputEnabled
        findButton.isHidden = !inputEnabled
        
        if activityVisible {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: Location
    
    //
    //  Retrieve coordinates for a given address. An error alert is shown if the address field is blank, or if geocoding
    //  fails. Transitions to the next screen on successfully geocoding the address.
    //
    private func performLookup() {

        // Get address entry. If no address is entered, then show an error and focus the location text field.
        guard let location = locationTextField.text, !location.isEmpty else {
            state = .pending
            let message = "Please enter your location."
            showAlert(forErrorMessage: message) { [weak self] in
                self?.locationTextField.becomeFirstResponder()
            }
            return
        }

        // Lookup the location.
        locationService.lookupAddress(location) { [weak self] result in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                
                switch result {

                // Geocoding was successful, continue to student info view controller.
                case .success(let location):
                    self.state = .pending
                    self.performSegue(withIdentifier: self.infoSegue, sender: location.first)
                    
                // Location lookup failed.
                case .failure(let error):
                    // An error was reported, show the alert, then go to the pending state.
                    self.showAlert(forError: error) { [weak self] in
                        self?.state = .pending
                    }
                }
            }
        }
    }
    
    // MARK: View controller life cycle
    
    //
    //  Configure view controllers before presentation.
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        // Segue to student info view controller.
        case let viewController as StudentInfoViewController:
            let coordinate = (sender as? CLPlacemark)?.location?.coordinate
            viewController.coordinate = coordinate
            viewController.address = locationTextField.text
            
        // Unexpected view controller.
        default:
            break
        }
    }
}

//
//  Text field delegate for location lookup view controller.
//
extension LocationLookupViewController: UITextFieldDelegate {
    
    //
    //  Called when done/return keyboard button is tapped. Dismiss the keyboard.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
