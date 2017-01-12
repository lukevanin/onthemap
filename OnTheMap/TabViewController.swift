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
    
    private let authentication = MockAuthentication() // Mock authenticator for testing
//    private let authentication = UdacityAuthentication()

    // MARK: View controller life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAuthenticationState()
    }

    // MARK: Authentication
    
    //
    //  Synchronize UI with authentication state. If user is not authenticated then show the login controller, otherwise
    //  if the user is not logged in then hide the login controller.
    //
    private func updateAuthenticationState() {
        if authentication.isAuthenticated {
            hideLoginViewController()
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
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            // Cannot instantiate the login view controller.
            return
        }
        viewController.delegate = self
        viewController.authentication = authentication
        present(viewController, animated: true, completion: nil)
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
}

//
//
//
extension TabViewController: LoginViewControllerDelegate {
    
    //
    //
    //
    func loginController(_ controller: LoginViewController, didAuthenticate: Bool) {
        if didAuthenticate {
            DispatchQueue.main.async {
                self.hideLoginViewController()
            }
        }
    }
}
