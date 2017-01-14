//
//  StudentManager.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

//import Foundation
//
//class StudentManager {
//    
//    typealias StudentUpdateCompletion = (Bool, Error?) -> Void
//    typealias StudentCompletion = (StudentInformation?, Error?) -> Void
//    typealias StudentsCompletion = ([StudentInformation]?, Error?) -> Void
//    
//    enum Response {
//        case success([StudentInformation])
//        case error(Error)
//    }
//    
//    typealias Completion = (Response) -> Void
//    
//    var students: [StudentInformation]?
//    
//    private let service: StudentService
//    
//    init(service: StudentService) {
//        self.service = service
//    }
//    
//    //
//    //  Add location information for the student.
//    //
//    func addStudentLocation(request: StudentRequest, completion: @escaping StudentUpdateCompletion) {
//        self.service.addStudent(student: request, completion: completion)
//    }
//    
//    //
//    //  Update existing location information.
//    //
//    func updateStudentLocation(objectId: String, request: StudentRequest,  completion: @escaping StudentUpdateCompletion) {
//        self.service.updateStudent(objectId: objectId, student: request, completion: completion)
//    }
//    
//    //
//    //  Fetch information for the current user. 
//    //  Returns nil if the user has not added a location yet.
//    //
//    func fetchCurrentStudent(completion: @escaping StudentCompletion) {
//        self.service.fetchCurrentStudent(completion: completion)
//    }
//    
//    //
//    //  Fetch information for all students.
//    //
//    func fetchAllStudents(completion: StudentsCompletion) {
//        
//    }
//}
