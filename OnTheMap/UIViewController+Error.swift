//
//  UIViewController+Error.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //
    //
    //
    func showAlert(forErrorMessage message: String, completion: @escaping ErrorAlertCompletion) {
        let controller = UIAlertController.alert(forErrorMessage: message, completion: completion)
        present(controller, animated: true, completion: nil)
    }
    
    //
    //
    //
    func showAlert(forError error: Error, completion: @escaping ErrorAlertCompletion) {
        let controller = UIAlertController.alert(forError: error, completion: completion)
        present(controller, animated: true, completion: nil)
    }
}
