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
    
    enum State {
        case pending
        case busy
    }
    
    private let dismissSegue = "dismiss"
    
    private let authenticationManager = AuthenticationManager(service: UdacityUserService(), credentials: Credentials.shared)
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
    //  Dismiss the modal without saving the student information.
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
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateMapOrientation(forTraits: newCollection)
    }
    
    // MARK: Map
    
    //
    //
    //
    private func updateMapOrientation(forTraits traits: UITraitCollection) {
        let isLandscape = (traits.verticalSizeClass == .compact)
        portraitMapView.superview?.isHidden = isLandscape
        landscapeMapView.superview?.isHidden = !isLandscape
    }
    
    //
    //
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
    //
    //
    private func updateMap(mapView: MKMapView, annotation: MKPointAnnotation, region: MKCoordinateRegion) {
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: State
    
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
    //
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
            mapString: address,
            mediaURL: mediaURL,
            longitude: coordinate.longitude,
            latitude: coordinate.latitude
        )
        
        let interactor = UpdateStudentInformationUseCase(
            location: location,
            authentication: authenticationManager,
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
