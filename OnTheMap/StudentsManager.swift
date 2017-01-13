//
//  StudentsManager.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class StudentsManager {
    
    enum Response {
        case success([StudentInformation])
        case error(Error)
    }
    
    typealias Completion = (Response) -> Void
    
    var students: [StudentInformation]?
    
    //
    //
    //
    func addStudent(student: StudentInformation) {
        
    }
    
    //
    //
    //
    func fetchStudents(completion: Completion) {
        
    }
}
