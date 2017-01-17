//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  View controller for login and signup. Presented modally by the tab bar controller.
//

import UIKit
import SafariServices
import FBSDKLoginKit

//
//  Delegate for the login controller. Delegates login actions to an external object.
//
protocol LoginControllerDelegate: class {
    typealias AuthenticationCompletion = (Result<Bool>) -> Void
    func login(username: String, password: String, completion: @escaping AuthenticationCompletion)
    func login(facebookToken: String, completion: @escaping AuthenticationCompletion)
}

class LoginViewController: UIViewController {
    
    enum State {
        case pending
        case busy
    }
    
    private let exitSegue = "dismiss"
    
    weak var delegate: LoginControllerDelegate?
    
    private var state: State = .pending {
        didSet {
            updateState()
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var udacityLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Actions
    
    //
    //  Sign up button tapped. Show web view to allow user to create an account.
    //
    @IBAction func onSignUpAction(_ sender: Any) {
        resignResponders()
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")
        let viewController = SFSafariViewController(url: url!)
        present(viewController, animated: true, completion: nil)
    }
    
    //
    //  Udacity login button tapped. Try to authenticate the user with the entered username and password.
    //
    @IBAction func onUdacityLoginAction(_ sender: Any) {
        
        // Resign focus from any input fields to dismiss the keyboard.
        resignResponders()
        
        // Get username text input. Show an error if the username field is blank.
        guard let username = usernameTextField.text, !username.isEmpty else {
            let message = "Please enter a username."
            showAlert(forErrorMessage: message) { [weak self] in
                self?.usernameTextField.becomeFirstResponder()
            }
            return
        }
        
        // Get password text input. Show an error if the password field is blank.
        guard let password = passwordTextField.text, !password.isEmpty else {
            let message = "Please enter a password."
            showAlert(forErrorMessage: message) { [weak self] in
                self?.passwordTextField.becomeFirstResponder()
            }
            return
        }
        
        // Attempt authentication with username and password.
        state = .busy
        delegate?.login(username: username, password: password, completion: self.handleLoginResponse)
    }
    
    //
    //  Facebook login button tapped. Authenticate the user with Facebook, then authorize the token with Udacity API.
    //
    @IBAction func onFacebookLoginAction(_ sender: Any) {
        
        // Resign focus from any input fields to dismiss the keyboard.
        resignResponders()
        state = .busy

        let login = FBSDKLoginManager()
        let permissions = ["public_profile"]
        login.logIn(withReadPermissions: permissions, from: self) { [weak self] (result, error) in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }

                // Show an error alert if an error occurred...
                if let error = error {
                    self.showAlert(forError: error)
                    return
                }
                
                // ... otherwise login with the facebook token.
                if let result = result, !result.isCancelled, let token = result.token.tokenString {
                    // Login to udacity with facebook token.
                    self.delegate?.login(facebookToken: token, completion: self.handleLoginResponse)
                }
            }
        }
    }
    
    //
    //  Resign focus from the input texfield and dismiss the keyboard.
    //
    private func resignResponders() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: Authentication

    //
    //  Process authentication response. Notify delegate
    //
    private func handleLoginResponse(_ result: Result<Bool>) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.state = .pending

            switch result {
                
            case .success(let isAuthenticated):
                if isAuthenticated {
                    // Authentication succeeded. Perform the exit segue to return to the presenting view controller.
                    self.performSegue(withIdentifier: self.exitSegue, sender: nil)
                }
                else {
                    // Authentication failed. Show an error message.
                    let message = "Cannot sign in. Please check your username and password, then try again."
                    self.showAlert(forErrorMessage: message)
                }
                
            case .failure(let error):
                // Error during authentication (e.g. network or content error).
                self.showAlert(forError: error)
            }
        }
    }
    
    // MARK: View life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }

    // MARK: State
    
    //
    //  Update the UI to display the current state. Disables input fields and shows activity indicator while login is 
    //  in progress.
    //
    private func updateState() {
        switch state {
        case .pending:
            configureUI(inputEnabled: true, activityVisible: false)
            
        case .busy:
            configureUI(inputEnabled: false, activityVisible: true)
        }
    }
    
    //
    //  Configure the UI with the state. Disables/enables text and button interaction, and shows/hides activity 
    //  indicator.
    //
    private func configureUI(inputEnabled: Bool, activityVisible: Bool) {
        usernameTextField.isEnabled = inputEnabled
        passwordTextField.isEnabled = inputEnabled
        udacityLoginButton.isEnabled = inputEnabled
        facebookLoginButton.isEnabled = inputEnabled
        signupButton.isEnabled = inputEnabled
        
        if activityVisible {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }
}

//
//  Text field delegate for login controller.
//
extension LoginViewController: UITextFieldDelegate {
    
    //
    //  Dismiss keyboard when done button is tapped.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
