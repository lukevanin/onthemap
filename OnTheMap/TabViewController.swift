//
//  TabViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Displays the content of the app, namely the login screen, location editor popup, and map and list tabs. Forwards 
//  state from the app controller to the child controllers, and actions from the child controllers back to the app 
//  controller.
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
    
    private var didAppear = false
    

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(hue: 30.0 / 360.0, saturation: 0.8, brightness: 0.8, alpha: 1.0)
        setupTabViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didAppear {
            didAppear = true
            updateAuthenticationState()
        }
    }
    
    // MARK: Setup
    
    //
    //  Initial configuration for child view controllers which represent the tabs to be displayed (map and list view 
    //  controllers).
    //
    private func setupTabViewControllers() {
        guard let viewControllers = self.viewControllers else {
            return
        }
        for viewController in viewControllers {
            setupTabViewController(viewController)
        }
    }
    
    //
    //  Configure a controller for the a tab. Sets the initial state from the app controller, and the delegate so that 
    //  the child controller communicates with the app controller.
    //
    //  Note: The content controllers themselves are each embedded in a navigation controller in order to obtain a nav 
    //  bar. This function uses recursion to descend the view controller hierarchy to access the content controller.
    //
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
    //  Callback action for unwind segues. Provides a way define how a presented view controller may to return to this 
    //  view controller using interface builder.
    //
    @IBAction func unwindToPresenter(_ sender: UIStoryboardSegue) {
        updateAuthenticationState()
    }
    
    //
    //  Prepare a view controller before presentation.
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepare(viewController: segue.destination, sender: sender)
    }
    
    //
    //  Prepare a view controller before presentation. This is a separate function to the built-in function so that 
    //  recursion can be implemented to traverse the view controller hierarchy.
    //
    private func prepare(viewController: UIViewController, sender: Any?) {
    
        switch viewController {
        
        // Segue to login view controller.
        case let viewController as LoginViewController:
            viewController.delegate = self.appController

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
    //  Iterates over the child view controllers. The iteractor is called for each view controller which conforms to
    //  StudentsControllerHandler. Used to propogate changes to child controllers using a universal interface.
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
    //  Provides a universal iterable interface to child view controllers conforming to StudentsController protocol. 
    //  Traverses controllers embedded in navigation controllers.
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
//  Extension which implements delegate methods for the app controller. This provides a way for the app controller to 
//  interact with the display state, without creating implementation dependencies.
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
