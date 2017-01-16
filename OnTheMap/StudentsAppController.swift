//
//  StudentsPresenter.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKLoginKit

struct AppState {
    var isLoggingOut: Bool
    var isFetchingStudents: Bool
    var isCheckingLocation: Bool
    var isActive: Bool {
        return isLoggingOut || isFetchingStudents || isCheckingLocation
    }
    
    init() {
        self.isLoggingOut = false
        self.isFetchingStudents = false
        self.isCheckingLocation = false
    }
}

protocol StudentsAppDelegate: NSObjectProtocol, ErrorAlertPresenter {
    func showLoginScreen()
    func showLocationEditScreen()
    func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?)
    func updateStudents(_ students: [StudentInformation]?)
    func updateState(_ state: AppState)
}

class StudentsAppController: StudentsControllerDelegate, LoginControllerDelegate {
    
    var isAuthenticated: Bool {
        return authentication.isAuthenticated
    }
    
    var state = AppState() {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = state.isActive
            delegate?.updateState(state)
        }
    }
    
    var students: [StudentInformation]? {
        didSet {
            self.delegate?.updateStudents(students)
        }
    }

    weak var delegate: StudentsAppDelegate?
    
    private let numberOfStudents = 100
    private let authentication = AuthenticationManager(service: UdacityUserService(), credentials: Credentials.shared)
    private let studentService = UdacityStudentService()
    
    // MARK: Features
    
    //
    //
    //
    func logout() {
        guard !state.isLoggingOut else {
            return
        }
        state.isLoggingOut = true
        FBSDKLoginManager().logOut()
        authentication.logout() { [weak self] _ in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.state.isLoggingOut = false
                self.delegate?.showLoginScreen()
            }
        }
    }
    
    //
    //
    //
    func addLocation() {
        guard !state.isCheckingLocation else {
            // Already checking location
            return
        }
        state.isCheckingLocation = true
        // Check if any location information exists for the user.
        checkIfUserHasLocation() { [weak self] result in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.state.isCheckingLocation = false
                switch result {
                    
                // Fetched entry status. Prompt to overwrite if user already has an entry.
                case .success(let hasLocation):
                    if hasLocation {
                        // Location information is present for the user. Prompt to overwrite it.
                        self.promptToOverwriteLocation() { overwrite in
                            if overwrite {
                                self.delegate?.showLocationEditScreen()
                            }
                        }
                    }
                    else {
                        // No existing location info. Show location popup.
                        self.delegate?.showLocationEditScreen()
                    }
                    
                // Error occurred checking if user has location.
                case .failure(let error):
                    self.delegate?.showAlert(forError: error, completion: nil)
                }
            }
        }
    }
    
    //
    //
    //
    private func checkIfUserHasLocation(completion: @escaping (Result<Bool>) -> Void) {
        // Fetch current auth session.
        authentication.fetchSession { [weak self] (result) in
            switch result {
                
            // Error fetching session.
            case .failure(let error):
                completion(Result.failure(error))
                
            // Fetched sesion. Fetch locations for user.
            case .success(let session):
                self?.studentService.fetchInformationForStudent(accountId: session.accountId) { (result) in
                    switch result {
                        
                    // Error fetching entries for student.
                    case .failure(let error):
                        completion(Result.failure(error))
                        
                    // Fetched entries. Check if student has any entries.
                    case .success(let entries):
                        let hasLocation = (entries.count > 0)
                        completion(Result.success(hasLocation))
                    }
                }
            }
        }
    }
    
    //
    //
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
    //
    //
    func showInformationForStudent(_ student: StudentInformation) {
        guard let url = student.location.validURL else {
            let message = "Item does not contain a valid media URL."
            delegate?.showAlert(forErrorMessage: message, completion: nil)
            return
        }
        let controller = SFSafariViewController(url: url)
        delegate?.present(controller, animated: true, completion: nil)
    }
    
    //
    //
    //
    func loadStudents() {
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
    //
    //
    func login(facebookToken: String, completion: @escaping LoginControllerDelegate.AuthenticationCompletion) {
        authentication.login(facebookToken: facebookToken, completion: completion)
    }
    
    //
    //
    //
    func login(username: String, password: String, completion: @escaping LoginControllerDelegate.AuthenticationCompletion) {
        authentication.login(username: username, password: password, completion: completion)
    }
}
