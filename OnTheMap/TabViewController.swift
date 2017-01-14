//
//  TabViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import SafariServices

class TabViewController: UITabBarController {
    
    // MARK: Properties
    
    private let loginSegue = "login"
    private let locationSegue = "location"
    private let numberOfStudents = 100
    
    private let authentication = AuthenticationManager(service: MockUdacityService(), credentials: Credentials.shared)
    private let studentService = MockStudentService()
    

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(hue: 30.0 / 360.0, saturation: 0.8, brightness: 0.8, alpha: 1.0)
        setupTabViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadStudents()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAuthenticationState()
    }
    
    // MARK: Setup
    
    private func setupTabViewControllers() {
        guard let viewControllers = self.viewControllers else {
            return
        }
        for viewController in viewControllers {
            setupTabViewController(viewController)
        }
    }
    
    private func setupTabViewController(_ viewController: UIViewController) {
        switch viewController {
            
        // Setup students information controller (map and list).
        case let controller as StudentsController:
            controller.delegate = self
            
        // Navigation controller - recurse to configure top-most view controller.
        case let navigationController as UINavigationController:
            if let viewController = navigationController.topViewController {
                setupTabViewController(viewController)
            }
            
        // Unknown view controller.
        default:
            break
        }
    }

    // MARK: Storyboard
    
    //
    //
    //
    @IBAction func unwindToPresenter(_ sender: UIStoryboardSegue) {
        
    }
    
    //
    //
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepare(viewController: segue.destination, sender: sender)
    }
    
    //
    //
    //
    private func prepare(viewController: UIViewController, sender: Any?) {
    
        switch viewController {
        
        // Segue to login view controller.
        case let viewController as LoginViewController:
            prepare(loginViewController: viewController)

        // Segue to a navigation controller - recurse into top-most view controller.
        case let navigationController as UINavigationController:
            if let viewController = navigationController.topViewController {
                prepare(viewController: viewController, sender: sender)
            }
            
        // No customisation needed.
        default:
            break
        }
    }
    
    //
    //
    //
    private func prepare(loginViewController viewController: LoginViewController) {
        viewController.delegate = self
        viewController.authentication = authentication
    }

    // MARK: Authentication
    
    //
    //  Synchronize UI with authentication state. 
    //  If user is authenticated then dismiss the login view and reload the student data show the login controller, otherwise
    //  if the user is not logged in then hide the login controller.
    //
    fileprivate func updateAuthenticationState() {
        if authentication.isAuthenticated {
            hideLoginViewController()
            reloadStudents()
        }
        else {
            showLoginViewController()
        }
    }
    
    //
    //  Show a modal login screen. If the login screen is already visible then this does nothing.
    //
    private func showLoginViewController() {
        guard presentedViewController == nil else {
            // Login view controller is already visible.
            return
        }
        
        // Instantiate and display the login controller.
        performSegue(withIdentifier: loginSegue, sender: nil)
    }

    //
    //  Dismiss and deallocate the login view controller. If the login controller is not visible then this does nothing.
    //
    fileprivate func hideLoginViewController() {
        guard let viewController = presentedViewController as? LoginViewController else {
            // Login view controller not showing.
            return
        }
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: App features
    
    //
    //
    //
    fileprivate func logout() {
        authentication.logout()
        updateAuthenticationState()
    }
    
    //
    //
    //
    fileprivate func addStudentLocation(sender: Any?) {
        
        // Check if any location information exists for the user.
        checkIfUserHasLocation() { result in
            DispatchQueue.main.async {
                switch result {
                    
                // Fetched entry status. Prompt to overwrite if user already has an entry.
                case .success(let hasLocation):
                    if hasLocation {
                        // Location information is present for the user. Prompt to overwrite it.
                        self.promptToOverwriteLocation() { overwrite in
                            if overwrite {
                                self.performSegue(withIdentifier: self.locationSegue, sender: sender)
                            }
                        }
                    }
                    else {
                        // No existing location info. Show location popup.
                        self.performSegue(withIdentifier: self.locationSegue, sender: sender)
                    }
                    
                // Error occurred checking if user has location.
                case .failure(let error):
                    self.showAlert(forError: error)
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
        
        present(controller, animated: true, completion: nil)
    }
    
    //
    //
    //
    fileprivate func showStudentInformation(_ student: StudentInformation, sender: Any?) {
        guard let url = makeURLForStudent(student.location.mediaURL) else {
            let message = "Item does not contain a valid media URL."
            showAlert(forErrorMessage: message)
            return
        }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
    
    //
    //
    //
    fileprivate func makeURLForStudent(_ input: String) -> URL? {

        guard var components = URLComponents(string: input) else {
            return nil
        }
        
        if components.scheme == nil {
            // Address is a valid URL, but is missing the scheme part, which will cause Safari view controller to crash. 
            // Try fix it by using HTTP scheme
            components.scheme = "http"
        }
        
        return components.url
    }
    
    //
    //
    //
    fileprivate func reloadStudents() {
        studentService.fetchLatestStudentInformation(count: numberOfStudents) { [weak self] result in
            guard let `self` = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                
                // Loaded students.
                case .success(let students):
                    self.updateViewControllers(students: students)
                    
                // Error loading students.
                case .failure(let error):
                    self.showAlert(forError: error)
                }
            }
        }
    }

    // MARK: App state
    
    //
    //
    //
    fileprivate func updateViewControllers(students: [StudentInformation]?) {
        guard let viewControllers = viewControllers else {
            return
        }
        for viewController in viewControllers {
            updateViewController(viewController, students: students)
        }
    }
    
    //
    //
    //
    fileprivate func updateViewController(_ viewController: UIViewController, students: [StudentInformation]?) {
        switch viewController {
        case let controller as StudentsController:
            controller.model = students
            
        case let navigationController as UINavigationController:
            if let viewController = navigationController.topViewController {
                updateViewController(viewController, students: students)
            }
            
        default:
            break
        }
    }
}

//
//
//
extension TabViewController: LoginViewControllerDelegate {
    
    //
    //  Called when login controller state changes, such as when the user logs in. Synchronize the app state with the 
    //  authentication state.
    //
    func loginController(_ controller: LoginViewController, didAuthenticate: Bool) {
        if didAuthenticate {
            DispatchQueue.main.async {
                self.updateAuthenticationState()
            }
        }
    }
}

//
//
//
extension TabViewController: StudentsControllerDelegate {
    
    //
    //  Called by students controllers.
    //
    func studentsController(controller: StudentsController, action: StudentsControllerAction, sender: Any?) {
        DispatchQueue.main.async {
            switch action {
            case .logout:
                self.logout()
            case .addLocation:
                self.addStudentLocation(sender: sender)
            case .showInformation(let student):
                self.showStudentInformation(student, sender: sender)
            case .refresh:
                self.reloadStudents()
            }
        }
    }
}
