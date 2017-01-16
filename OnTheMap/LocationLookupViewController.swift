//
//  LocationLookupViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MapKit

class LocationLookupViewController: UIViewController {
    
    enum State {
        case pending
        case busy
    }
    
//    private let locationService: LocationService = {
//        let coordinate = CLLocationCoordinate2D(
//            latitude: 40.7483,
//            longitude: -73.984911
//        )
//        let placemark = MKPlacemark(coordinate: coordinate)
//        return MockLocationService(placemarks: Result.success([placemark]), error: nil)
//    }()
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
    //
    //
    @IBAction func onFindButtonAction(_ sender: Any) {
        locationTextField.resignFirstResponder()
        state = .busy
        performLookup()
    }

    //
    //
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
    //
    //
    private func updateState() {
        switch state {
        
        case .pending:
            configureUI(inputEnabled: true)
            
        case .busy:
            configureUI(inputEnabled: false)
        }
    }
    
    //
    //
    //
    private func configureUI(inputEnabled: Bool) {
        locationTextField.isEnabled = inputEnabled
        findButton.isHidden = !inputEnabled
        
        if inputEnabled {
            activityIndicator.stopAnimating()
        }
        else {
            activityIndicator.startAnimating()
        }
    }
    
    // MARK: Location
    
    //
    //
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
    //
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
//
//
extension LocationLookupViewController: UITextFieldDelegate {
    
    //
    //
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
