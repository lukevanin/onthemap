//
//  StudentService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Provides functionality for retrieving and modifying student information.
//

import Foundation

typealias FetchStudentsCompletion = (Result<[StudentInformation]>) -> Void
typealias UpdateStudentCompletion = (Result<Void>) -> Void

protocol StudentService {
    
    //
    //  Retrieve information entries for a given account ID. Used to obtain the entries for the current logged in user.
    //
    func fetchInformationForStudent(accountId: String, completion: @escaping FetchStudentsCompletion)
    
    //
    //  Retrieve latest student information entries.
    //
    func fetchLatestStudentInformation(count: Int, completion: @escaping FetchStudentsCompletion)
    
    //
    //  Insert a new student information entity.
    //
    func addStudentInformation(student: StudentRequest, completion: @escaping UpdateStudentCompletion)
    
    //
    //  Update an existing student information entity with a given object ID.
    //
    func updateStudentInformation(objectId: String, student: StudentRequest, completion: @escaping UpdateStudentCompletion)
}
