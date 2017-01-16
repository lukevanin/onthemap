//
//  StudentsViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Defines an abstract interface for displaying students.
//  Implemented by MapViewController and ListViewController.
//

import UIKit

enum StudentsControllerAction {
    case logout
    case addLocation
    case showInformation(StudentInformation)
    case refresh
}

protocol StudentsControllerDelegate: class {
    func studentsController(controller: StudentsController, action: StudentsControllerAction, sender: Any?)
}

protocol StudentsController: class {
    
    var model: [StudentInformation]? {
        get
        set
    }
    
    weak var delegate: StudentsControllerDelegate? {
        get
        set
    }
    
    var viewController: UIViewController {
        get
    }
}
