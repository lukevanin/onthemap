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
        appController.loadStudents()
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
            
        // Setup app controller as delegate for map view.
        case let controller as MapViewController:
            controller.delegate = appController
            
        // Setup app controller as delegate for list view.
        case let controller as ListViewController:
            controller.delegate = appController
            
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
        appController.loadStudents()
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
}
