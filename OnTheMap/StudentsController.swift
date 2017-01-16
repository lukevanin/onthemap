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

protocol StudentsControllerDelegate: class {
    func logout()
    func addLocation()
    func showInformationForStudent(_ student: StudentInformation)
    func loadStudents()
}

protocol StudentsController: class {
    
    var state: AppState {
        get
        set
    }
    
    var model: [StudentInformation]? {
        get
        set
    }
    
    weak var delegate: StudentsControllerDelegate? {
        get
        set
    }
}
