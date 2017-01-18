//
//  StudentsModel.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let StudentsModelChanged = NSNotification.Name(rawValue: "StudentsModelChanged")
}

class StudentsModel {
    
    //
    //  Shared singleton instance.
    //
    static let shared = StudentsModel()
    
    //
    //  Student information items. Changing this property produces a StudentsModelChanged notification.
    //
    var students = [StudentInformation]() {
        didSet {
            NotificationCenter.default.post(name: .StudentsModelChanged, object: self)
        }
    }
}
