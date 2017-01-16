//
//  UIAlertController+Error.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Convenience methods for showing error alerts.
//

import UIKit

typealias ErrorAlertCompletion = () -> Void

extension UIAlertController {
    
    class func alert(forError error: Error, completion: ErrorAlertCompletion? = nil) -> UIAlertController {
        let message = error.localizedDescription
        return alert(forErrorMessage: message, completion: completion)
    }
    
    class func alert(forErrorMessage message: String, completion: ErrorAlertCompletion? = nil) -> UIAlertController {
        let title = "Oops, something went wrong!"
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
            completion?()
        }
        controller.addAction(action)
        return controller
    }
}
