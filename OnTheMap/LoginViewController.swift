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
class LoginViewController: UIViewController {
    
    enum State {
        case pending
        case busy
    }
    
    private let contentSegue = "content"
    
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
    //
    //
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        
    }
    
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
        
        let userService = UdacityUserService()
        let interactor = LoginUseCase(
            request: .credentials(username: username, password: password),
            service: userService,
            completion: handleLoginResult
        )
        interactor.execute()
    }
    
    //
    //  Facebook login button tapped. Authenticate the user with Facebook, then authorize the token with Udacity API.
    //
    @IBAction func onFacebookLoginAction(_ sender: Any) {
        
        // Resign focus from any input fields to dismiss the keyboard.
        resignResponders()
        state = .busy
        
        facebookLogin(completion: handleLoginResult)
    }
    
    //
    //
    //
    private func facebookLogin(completion: @escaping (Result<Bool>) -> Void) {

        let login = FBSDKLoginManager()
        let permissions = ["public_profile"]
        login.logIn(withReadPermissions: permissions, from: self) { (result, error) in

            // Show an error alert if an error occurred...
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // ... otherwise login with the facebook token.
            
            guard let result = result else {
                // Facebook login did not return an error or a result. Show error and go back to pending.
                let error = ServiceError.response
                completion(.failure(error))
                return
            }
            
            guard !result.isCancelled else {
                // Operation cancelled by user. Just go back to the pending state.
                completion(.success(false))
                return
            }
            
            guard let token = result.token.tokenString else {
                // No token returned in result.
                let error = ServiceError.authentication
                completion(.failure(error))
                return
            }
        
            // Login to udacity with facebook token.
            let interactor = LoginUseCase(
                request: .facebook(token: token),
                service: UdacityUserService(),
                completion: completion
            )
            interactor.execute()
        }
    }

    //
    //
    //
    private func handleLoginResult(_ result: Result<Bool>) {
        DispatchQueue.main.async {
            self.state = .pending
            
            switch result {
                
            case .success(let isAuthenticated):
                // Logged in successfully with facebook.
                if isAuthenticated {
                    self.showContent()
                }
                
            case .failure(let error):
                // Facebook login failed. Show error
                self.showAlert(forError: error)
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
    
    //
    //  Show the primary app content after successful login.
    //
    private func showContent() {
        performSegue(withIdentifier: self.contentSegue, sender: nil)
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
