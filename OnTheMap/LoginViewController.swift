//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import SafariServices

typealias AlertCompletion = () -> Void

protocol LoginViewControllerDelegate: class {
    func loginController(_ controller: LoginViewController, didAuthenticate: Bool)
}

class LoginViewController: UIViewController {
    
    var authentication: Authentication!
    weak var delegate: LoginViewControllerDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: Actions
    
    //
    // Sign up button tapped. Show web view to allow user to create an account.
    //
    @IBAction func onSignUpAction(_ sender: Any) {
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")
        let viewController = SFSafariViewController(url: url!)
        present(viewController, animated: true, completion: nil)
    }
    
    //
    //  Udacity login button tapped. Try to authenticate the user with the entered username and password.
    //
    @IBAction func onUdacityLoginAction(_ sender: Any) {
        
        // Get username text input.
        guard let username = usernameTextField.text, !username.isEmpty else {
            let message = "Please enter a username."
            showAlert(error: message) { [weak self] in
                self?.usernameTextField.becomeFirstResponder()
            }
            return
        }
        
        // Get password text input.
        guard let password = passwordTextField.text, !password.isEmpty else {
            let message = "Please enter a password."
            showAlert(error: message) { [weak self] in
                self?.passwordTextField.becomeFirstResponder()
            }
            return
        }
        
        // Attempt authentication with username and password.
        authentication.login(username: username, password: password, completion: handleLoginResponse)
    }
    
    //
    //  Facebook login button tapped. Authenticate the user with Facebook, then authorize the token with Udacity API.
    //
    @IBAction func onFacebookLoginAction(_ sender: Any) {
//        authentication.loginWithFacebook(token: token), completion: handleLogin)
    }
    
    // MARK: Authentication

    private func handleLoginResponse(_ response: AuthenticationResponse) {
        switch response {
        case .authenticated:
            delegate?.loginController(self, didAuthenticate: true)
        case .error(let error):
            delegate?.loginController(self, didAuthenticate: false)
            handleError(error)
        }
    }
    
    private func handleError(_ error: AuthenticationError) {
        let message: String
        switch (error) {
        case .credentials:
            message = "Your username or password is incorrect. Please check your entry and try again."
        case .network:
            message = "Please check your internet connection and try again."
        }
        DispatchQueue.main.async {
            self.showAlert(error: message)
        }
    }
    
    private func showAlert(error message: String, completion: AlertCompletion? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
            completion?()
        }
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: View life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // FIXME: Go to next text field, otherwise submit.
        return true
    }
}
