//
//  UIViewController+Error.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

protocol ErrorAlertPresenter {
    func showAlert(forErrorMessage message: String, completion: ErrorAlertCompletion?)
    func showAlert(forError error: Error, completion: ErrorAlertCompletion?)
}

extension UIViewController: ErrorAlertPresenter {
    
    //
    //
    //
    func showAlert(forErrorMessage message: String, completion: ErrorAlertCompletion? = nil) {
        let controller = UIAlertController.alert(forErrorMessage: message, completion: completion)
        present(controller, animated: true, completion: nil)
    }
    
    //
    //
    //
    func showAlert(forError error: Error, completion: ErrorAlertCompletion? = nil) {
        let controller = UIAlertController.alert(forError: error, completion: completion)
        present(controller, animated: true, completion: nil)
    }
}
