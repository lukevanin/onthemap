//
//  StudentsAppController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Primary application controller. Coordinates overall app behaviour, and delegates actions to and from view 
//  controllers. This controller maintains the state of the application, such as controlling login state, and when
//  view controllers should appear.
//
//  This loosely follows the presenter pattern in MVP and VIPER, as it contains application behavior and delegates to
//  services for business logic, while forwarding information to views for display.
//

import UIKit
import SafariServices
import FBSDKLoginKit

//
//  Delegate protocol for app controller. Currently this is implemented by the TabViewController, and potentially other
//  "container" controllers such as a master detail view controller.
//
protocol StudentsAppDelegate: NSObjectProtocol, ErrorAlertPresenter {
    func showLoginScreen()
    func showLocationEditScreen()
    func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?)
}

//
//  Delegate actions for view controllers which display students. Used by map and list view controllers which need
//  to perform the same actions. Placing this functionality in the delegate removes the need to duplicate the behavior
//  in each view controller.
//
protocol StudentsControllerDelegate: class {
    func logout()
    func addLocation()
    func showInformationForStudent(_ student: StudentInformation)
    func loadStudents()
}

class StudentsAppController: StudentsControllerDelegate {
    
    //
    //  State of the application. Describes actions which the app performs. Setting this value updates the status bar 
    //  network activity indicator when one or more actions is underway. The state is also propogated to the delegate, 
    //  where it is used to update the nav bar button items on the map and list screens.
    //
    let state = AppState.shared
    
    //
    //  Currently loaded student data. Setting this value propogates the data to the delegate, which updates the map
    //  and list screens.
    //
    let model = StudentsModel.shared

    //
    //  Delegate. Implemented by the primary content view controller.
    //
    weak var delegate: StudentsAppDelegate?
    
    //
    //  Number of students to load from the web service API.
    //
    private let numberOfStudents = 100
    
    // MARK: Life cycle
    
    init() {
        addNotificationObservers()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    // MARK: Notifications
    
    //
    //  Observe changes to the model.
    //
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onAppStateChanged), name: .AppStateChanged, object: state)
    }
    
    //
    //  Stop observing changes to the model.
    //
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .AppStateChanged, object: model)
        
    }
    
    //
    //  Update the navigation bar when the app state changes.
    //
    @objc func onAppStateChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            UIApplication.shared.isNetworkActivityIndicatorVisible = self?.state.isActive ?? false
        }
    }
    
    // MARK: Features
    
    //
    //  Log out from Facebook and Udacity API. 
    //  App state ensures that only one logout operation can execute at a time.
    //
    func logout() {
        
        // Ensure single log out transaction.
        guard !state.isLoggingOut else {
            return
        }
        state.isLoggingOut = true
        
        let userService = UdacityUserService()
        let interactor = LogoutUseCase(service: userService) { [weak self] _ in
            DispatchQueue.main.async {
                self?.state.isLoggingOut = false
                self?.delegate?.showLoginScreen()
            }
        }
        
        interactor.execute()
    }
    
    //
    //  Add user's location to the server database. If user already has an entry in the database then a prompt is shown
    //  to overwrite the entry, or cancel the task. If there is no entry for the user, or the user elects to overwrite
    //  an existing entry, then the delegate is called to show the location edit screen. 
    //
    //  App state ensures only one task can execute at a time.
    //
    func addLocation() {
        
        // Prevent duplicate concurrent opration.
        guard !state.isCheckingLocation else {
            // Already checking location
            return
        }
        state.isCheckingLocation = true
        
        // Check if any location information exists for the user.
        let studentService = UdacityStudentService()
        let interactor = CheckExistingStudentUseCase(studentService: studentService) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.state.isCheckingLocation = false
                
                // Handle result.
                switch result {
                    
                // Fetched entry status. Prompt to overwrite if user already has an entry.
                case .success(let hasLocation):
                    if hasLocation {
                        // Location information is present for the user. Prompt to overwrite it.
                        self.promptToOverwriteLocation() { overwrite in
                            if overwrite {
                                // User elected to overwrite existing location, show the edit screen.
                                self.delegate?.showLocationEditScreen()
                            }
                        }
                    }
                    else {
                        // No existing location info. Show edit screen.
                        self.delegate?.showLocationEditScreen()
                    }
                    
                // Error occurred checking if user has location.
                case .failure(let error):
                    self.delegate?.showAlert(forError: error, completion: nil)
                }
            }
        }
        
        interactor.execute()
    }
    
    //
    //  Create and show an alert to prompt the user to overwrite an existing location. Called before adding a location 
    //  if the user already has a location.
    //
    private func promptToOverwriteLocation(completion: @escaping (Bool) -> Void) {
        let message = "Do you want to overwrite your existing location?"
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // Overwrite action
        controller.addAction(
            UIAlertAction(
                title: "Overwrite",
                style: .destructive,
                handler: { (action) in
                    completion(true)
            })
        )
        
        // Dismiss action
        controller.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { (action) in
                    completion(false)
            })
        )
        
        delegate?.present(controller, animated: true, completion: nil)
    }

    //
    //  Show the web site with the URL for the student entity. An error is shown if the URL is not valid.
    //
    func showInformationForStudent(_ student: StudentInformation) {
        guard let url = student.location.validURL else {
            let message = "Item does not contain a valid media URL."
            delegate?.showAlert(forErrorMessage: message, completion: nil)
            return
        }
        
        // Show the URL in an embedded Safari controller.
        let controller = SFSafariViewController(url: url)
        delegate?.present(controller, animated: true, completion: nil)
    }
    
    //
    //  Load latest student info from the web service API. An error alert is shown if the request fails.
    //
    func loadStudents() {
        
        // Prevent duplicate operations.
        guard !state.isFetchingStudents else {
            // Already fetching
            return
        }
        state.isFetchingStudents = true
        
        let studentService = UdacityStudentService()
        studentService.fetchLatestStudentInformation(count: numberOfStudents) { [weak self] result in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.state.isFetchingStudents = false
                switch result {
                    
                // Loaded students.
                case .success(let students):
                    self.model.students = students
                    
                // Error loading students.
                case .failure(let error):
                    self.delegate?.showAlert(forError: error, completion: nil)
                }
            }
        }
    }
}
