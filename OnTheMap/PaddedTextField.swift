//
//  PaddedTextField.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class PaddedTextField: UITextField {
    
    var padding = CGSize(width: 4.0, height: 4.0)
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding.width, dy: padding.height)
    }
}
