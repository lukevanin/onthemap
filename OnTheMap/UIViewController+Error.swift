//
//  UIViewController+Error.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Convenience methods for showing error alerts.
//

import UIKit

protocol ErrorAlertPresenter {
    func showAlert(forErrorMessage message: String, completion: ErrorAlertCompletion?)
    func showAlert(forError error: Error, completion: ErrorAlertCompletion?)
}

extension UIViewController: ErrorAlertPresenter {
    
    //
    //  Show an alert for an error object using the localized description of the error. The completion handler is called
    //  after the alert is dismissed.
    //
    func showAlert(forErrorMessage message: String, completion: ErrorAlertCompletion? = nil) {
        let controller = UIAlertController.alert(forErrorMessage: message, completion: completion)
        present(controller, animated: true, completion: nil)
    }
    
    //
    //  Show a generic error alert with a dismiss button. The completion handler is called after the alert is dismissed.
    //
    func showAlert(forError error: Error, completion: ErrorAlertCompletion? = nil) {
        let controller = UIAlertController.alert(forError: error, completion: completion)
        present(controller, animated: true, completion: nil)
    }
}
