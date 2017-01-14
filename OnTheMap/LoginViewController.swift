//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import SafariServices

protocol LoginViewControllerDelegate: class {
    func loginController(_ controller: LoginViewController, didAuthenticate: Bool)
}

class LoginViewController: UIViewController {
    
    var authentication: AuthenticationManager!
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
        authentication.login(username: username, password: password, completion: handleLoginResponse)
    }
    
    //
    //  Facebook login button tapped. Authenticate the user with Facebook, then authorize the token with Udacity API.
    //
    @IBAction func onFacebookLoginAction(_ sender: Any) {
//        authentication.loginWithFacebook(token: token), completion: handleLogin)
    }
    
    // MARK: Authentication

    //
    //  Process authentication response. Notify delegate
    //
    private func handleLoginResponse(_ result: Result<Bool>) {
        
        switch result {
            
        case .success(let isAuthenticated):
            delegate?.loginController(self, didAuthenticate: isAuthenticated)
            
        case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.showAlert(forError: error) {
                    self.delegate?.loginController(self, didAuthenticate: false)
                }
            }
        }
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
