//
//  WebsiteViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Screen 2 of 2 for adding a location.
//
//  Shows a geocoded location on a map. Allows the user to enter a web address to store with the location. Uploads 
//  student information entity to the server. If an entity already exists then it is overwritten.
//

import UIKit
import MapKit

class StudentInfoViewController: UIViewController {
    
    enum State {
        case pending
        case busy
    }
    
    private let dismissSegue = "dismiss"
    
    private let studentService = UdacityStudentService()
    
    var address: String?
    var coordinate: CLLocationCoordinate2D?
    
    private var state: State = .pending {
        didSet {
            self.updateState()
        }
    }

    // MARK: Outlets
    
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var portraitMapView: MKMapView!
    @IBOutlet weak var landscapeMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: Actions
    
    //
    //  Called when user taps submit button. Compose student information and send to web service. 
    //  If the web service call fails, then show an error message. 
    //  If the web service call succeeds, then show a success message, dismiss the view controller, and show the new 
    //  location on the map.
    //
    @IBAction func onSubmitButtonAction(_ sender: Any) {
        websiteTextField.resignFirstResponder()
        state = .busy
        storeStudentInformation()
    }
    
    //
    //  Cancel button tapped. Dismiss the modal without saving the student information.
    //
    @IBAction func onCancelButtonAction(_ sender: Any) {
        performSegue(withIdentifier: dismissSegue, sender: sender)
    }
    
    // MARK: View controller life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMapOrientation(forTraits: traitCollection)
        updateMapWithLocation()
        updateState()
    }
    
    //
    //  Update the UI when the device switches to/from compact horizontal mode.
    //
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateMapOrientation(forTraits: newCollection)
    }
    
    // MARK: Map
    
    //
    //  Configure the UI depending on the layout traits. To support landscape/portrait mode the view controller uses
    //  two map views, inserted at different levels in the view hierarchy (see the storyboard for clarification). One 
    //  view is shown only in portrait mode, and one is shown only in landscape mode. This allows the view to emulate 
    //  different layouts without having to modify the hierarchy or constraints.
    //
    private func updateMapOrientation(forTraits traits: UITraitCollection) {
        let isLandscape = (traits.verticalSizeClass == .compact)
        portraitMapView.superview?.isHidden = isLandscape
        landscapeMapView.superview?.isHidden = !isLandscape
    }
    
    //
    //  Updates the map view(s) to show a given location (the geocoded location from the previous screen).
    //
    private func updateMapWithLocation() {
        guard let coordinate = coordinate else {
            return
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        updateMap(mapView: portraitMapView, annotation: annotation, region: region)
        updateMap(mapView: landscapeMapView, annotation: annotation, region: region)
    }
    
    //
    //  Configure map view to show a specific annotation and region.
    //
    private func updateMap(mapView: MKMapView, annotation: MKPointAnnotation, region: MKCoordinateRegion) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: State
    
    //
    //  Update the UI to display the current state. Disables UI input and shows activity indicator while calling the 
    //  server API.
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
    //  Configure the UI. Disables/enables UI input. Shows/hides activity indicator.
    //
    private func configureUI(inputEnabled: Bool) {
        websiteTextField.isEnabled = inputEnabled
        submitButton.isHidden = !inputEnabled
        
        if inputEnabled {
            activityIndicator.stopAnimating()
        }
        else {
            activityIndicator.startAnimating()
        }
    }
    
    // MARK: Student info
    
    //
    //  Update the student's information in the web server database. Returns to the pending state if unsuccessful. If 
    //  information is updated sucessfully, the modal popup is dismissed and the app returns to the main view 
    //  controller.
    //
    private func storeStudentInformation() {
        updateStudentInformation() { [weak self] success in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                if (success) {
                    // Student updated successfully, dismiss the modal and return to the main screen.
                    self.performSegue(withIdentifier: self.dismissSegue, sender: nil)
                }
                else {
                    // An error ocurred, return to the input state.
                    self.state = .pending
                }
            }
        }
    }

    //
    //  Updates the student information. Shows an error alert if the address or coordinate is missing, or if an error
    //  occurs during the update. The actual update process is delegate to a use case.
    //
    private func updateStudentInformation(completion: @escaping (Bool) -> Void) {
        
        // Location.
        guard let address = address, let coordinate = coordinate else {
            let message = "Please return to the previous screen and provide your location."
            showAlert(forErrorMessage: message) {
                completion(false)
            }
            return
        }
        
        // Media URL
        guard let mediaURL = websiteTextField.text, !mediaURL.isEmpty else {
            let message = "Please enter a URL."
            showAlert(forErrorMessage: message) { [weak self] in
                self?.websiteTextField.becomeFirstResponder()
                completion(false)
            }
            return
        }
        
        // Make location
        let location = StudentLocation(
            mediaURL: mediaURL,
            mapString: address,
            longitude: coordinate.longitude,
            latitude: coordinate.latitude
        )
        
        // Call interactor.
        let userService = UdacityUserService()
        let studentService = UdacityStudentService()
        let interactor = UpdateStudentInformationUseCase(
            location: location,
            userService: userService,
            studentService: studentService) { [weak self] (success, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showAlert(forError: error) {
                            completion(false)
                        }
                    }
                }
                else {
                    completion(success)
                }
        }
        
        interactor.execute()
    }
}

//
//
//
extension StudentInfoViewController: UITextFieldDelegate {
    
    //
    //
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
