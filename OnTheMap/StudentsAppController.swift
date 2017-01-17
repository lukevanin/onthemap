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
    func updateStudents(_ students: [StudentInformation]?)
    func updateState(_ state: AppState)
}

class StudentsAppController: StudentsControllerDelegate, LoginControllerDelegate {
    
    //
    //  Authentication state. True if the user is authenticated with a valid session, or false otherwise.
    //
    var isAuthenticated: Bool {
        return authentication.isAuthenticated
    }
    
    //
    //  State of the application. Describes actions which the app performs. Setting this value updates the status bar 
    //  network activity indicator when one or more actions is underway. The state is also propogated to the delegate, 
    //  where it is used to update the nav bar button items on the map and list screens.
    //
    var state = AppState() {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = state.isActive
            delegate?.updateState(state)
        }
    }
    
    //
    //  Currently loaded student data. Setting this value propogates the data to the delegate, which updates the map
    //  and list screens.
    //
    var students: [StudentInformation]? {
        didSet {
            self.delegate?.updateStudents(students)
        }
    }

    weak var delegate: StudentsAppDelegate?
    
    //
    //  Number of students to load from the web service API.
    //
    private let numberOfStudents = 100
    
    //
    //  Authentication manager which controls the user authentication. Pass in MockUserService to emulate API behaviors.
    //
    private let authentication = AuthenticationManager(service: UdacityUserService(), credentials: Credentials.shared)
    
    //
    //  Facade for interacting with the student related data in the web service API. Replace with MockStudentService to
    //  emulate API functionality.
    //
    private let studentService = UdacityStudentService()
    
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
        
        let interactor = LogoutUseCase(authentication: authentication) { [weak self] in
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
        let interactor = CheckExistingStudentUseCase(
            studentService: studentService,
            authentication: authentication) { [weak self] (result) in
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
        
        studentService.fetchLatestStudentInformation(count: numberOfStudents) { [weak self] result in
            guard let `self` = self else {
                return
            }
            DispatchQueue.main.async {
                self.state.isFetchingStudents = false
                switch result {
                    
                // Loaded students.
                case .success(let students):
                    self.students = students
                    
                // Error loading students.
                case .failure(let error):
                    self.delegate?.showAlert(forError: error, completion: nil)
                }
            }
        }
    }
    
    // MARK: Authentication
    
    //
    //  Authenticate the user with a Facebook token. The token is obtained by authenticating using the Facebook web API.
    //
    func login(facebookToken: String, completion: @escaping LoginControllerDelegate.AuthenticationCompletion) {
        authentication.login(facebookToken: facebookToken, completion: completion)
    }
    
    //
    //  Authenticate the user with username and password credentials.
    //
    func login(username: String, password: String, completion: @escaping LoginControllerDelegate.AuthenticationCompletion) {
        authentication.login(username: username, password: password, completion: completion)
    }
}
