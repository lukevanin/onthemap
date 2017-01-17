//
//  TabViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKLoginKit

class TabViewController: UITabBarController {
    
    typealias StudentsControllerHandler = (StudentsController) -> Void
    
    // MARK: Properties
    
    fileprivate let loginSegue = "login"
    fileprivate let locationSegue = "location"
    
    private lazy var appController: StudentsAppController = {
        let instance = StudentsAppController()
        instance.delegate = self
        return instance
    }()
    

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(hue: 30.0 / 360.0, saturation: 0.8, brightness: 0.8, alpha: 1.0)
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
            controller.delegate = appController
            controller.state = appController.state
            
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
        viewController.delegate = self.appController
    }

    // MARK: Authentication
    
    //
    //  Synchronize UI with authentication state. 
    //  If user is authenticated then dismiss the login view and reload the student data show the login controller, otherwise
    //  if the user is not logged in then hide the login controller.
    //
    fileprivate func updateAuthenticationState() {
        if appController.isAuthenticated {
            appController.loadStudents()
        }
        else {
            showLoginScreen()
        }
    }

    // MARK: App state
    
    //
    //
    //
    fileprivate func updateViewControllers(iterator: StudentsControllerHandler) {
        guard let viewControllers = viewControllers else {
            return
        }
        for viewController in viewControllers {
            updateViewController(viewController, iterator: iterator)
        }
    }

    //
    //
    //
    fileprivate func updateViewController(_ viewController: UIViewController, iterator: StudentsControllerHandler) {
        switch viewController {
        case let controller as StudentsController:
            iterator(controller)
            
        case let navigationController as UINavigationController:
            if let viewController = navigationController.topViewController {
                updateViewController(viewController, iterator: iterator)
            }
            
        default:
            break
        }
    }
}

//
//
//
extension TabViewController: StudentsAppDelegate {
    
    func showLoginScreen() {
        performSegue(withIdentifier: loginSegue, sender: nil)
    }
    
    func showLocationEditScreen() {
        performSegue(withIdentifier: locationSegue, sender: nil)
    }
    
    func updateStudents(_ students: [StudentInformation]?) {
        updateViewControllers() { controller in
            controller.model = students
        }
    }
    
    func updateState(_ state: AppState) {
        updateViewControllers() { controller in
            controller.state = state
        }
    }
}
