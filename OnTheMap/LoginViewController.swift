//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKLoginKit

protocol LoginViewControllerDelegate: class {
    func loginController(_ controller: LoginViewController, didAuthenticate: Bool)
}

class LoginViewController: UIViewController {
    
    enum State {
        case pending
        case busy
    }
    
    var authentication: AuthenticationManager!
    weak var delegate: LoginViewControllerDelegate?
    
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
    // Sign up button tapped. Show web view to allow user to create an account.
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
        resignResponders()
        
        // Get username text input.
        guard let username = usernameTextField.text, !username.isEmpty else {
            let message = "Please enter a username."
            showAlert(forErrorMessage: message) { [weak self] in
                self?.usernameTextField.becomeFirstResponder()
            }
            return
        }
        
        // Get password text input.
        guard let password = passwordTextField.text, !password.isEmpty else {
            let message = "Please enter a password."
            showAlert(forErrorMessage: message) { [weak self] in
                self?.passwordTextField.becomeFirstResponder()
            }
            return
        }
        
        // Attempt authentication with username and password.
        state = .busy
        authentication.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.state = .pending
                self.handleLoginResponse(result)
            }
        }
    }
    
    //
    //  Facebook login button tapped. Authenticate the user with Facebook, then authorize the token with Udacity API.
    //
    @IBAction func onFacebookLoginAction(_ sender: Any) {
        resignResponders()
        state = .busy

        let login = FBSDKLoginManager()
        let permissions = ["public_profile"]
        login.logIn(withReadPermissions: permissions, from: self) { [weak self] (result, error) in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }

                self.state = .pending

                // Show an error alert if an error occurred...
                if let error = error {
                    self.showAlert(forError: error)
                    return
                }
                
                // ... otherwise login with the facebook token.
                if let result = result, !result.isCancelled, let token = result.token.tokenString {
                    // Login to udacity with facebook token.
                    self.authentication.login(facebookToken: token, completion: self.handleLoginResponse)
                }
            }
        }
    }
    
    //
    //
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
        
        switch result {
            
        case .success(let isAuthenticated):
            if isAuthenticated {
                delegate?.loginController(self, didAuthenticate: isAuthenticated)
            }
            else {
                DispatchQueue.main.async { [weak self] in
                    let message = "Cannot sign in. Please check your username and password, then try again."
                    self?.showAlert(forErrorMessage: message)
                }
            }
            
        case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(forError: error)
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
    //
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
    //
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
//
//
extension LoginViewController: UITextFieldDelegate {
    
    //
    //
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
