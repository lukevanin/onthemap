//
//  TabViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    
    // MARK: Properties
    
    private let loginSegue = "login"
    private let locationSegue = "location"
    
    private let authentication: AuthenticationManager = {
        let service = MockUdacityService()
        let credentials = Credentials.shared
        return AuthenticationManager(service: service, credentials: credentials)
    }()
    
    private var students: [StudentInformation]?

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .white
        delegate = self
        setupTabViewControllers()
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

        // Segue to location lookup view controller.
        case let viewController as LocationLookupViewController:
            prepare(locationLookupViewController: viewController)
            
        // Segue to a navigation controller - recurse into top-most view controller.
        case let navigationController as UINavigationController:
            if let viewController = navigationController.topViewController {
                prepare(viewController: viewController, sender: sender)
            }
            
        // Segue to unexpected view controller
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
    
    //
    //
    //
    private func prepare(locationLookupViewController viewController: LocationLookupViewController) {
        // TODO: Implement
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
            updateSelectedViewController()
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
        performSegue(withIdentifier: locationSegue, sender: sender)
    }
    
    //
    //
    //
    fileprivate func showStudentInformation(_ student: StudentInformation, sender: Any?) {
        
    }
    
    //
    //
    //
    fileprivate func reloadStudents() {
        
    }

    // MARK: App state
    
    //
    //
    //
    fileprivate func updateSelectedViewController() {
        if let viewController = selectedViewController {
            updateViewController(viewController)
        }
    }
    
    //
    //
    //
    fileprivate func updateViewController(_ viewController: UIViewController) {
        guard let controller = viewController as? StudentsController else {
            return
        }
        controller.model = students
    }
}

//
//
//
extension TabViewController: UITabBarControllerDelegate {
    
    //
    //  Called when user taps on a tab bar item to switch to a different tab. Synchronize the new view controller with 
    //  the current app state.
    //
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        updateViewController(viewController)
        return true
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
