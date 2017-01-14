//
//  StudentService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

typealias FetchStudentsCompletion = (Result<[StudentInformation]>) -> Void
typealias UpdateStudentCompletion = (Result<Void>) -> Void

protocol StudentService {
    
    //
    //
    //
    func fetchInformationForStudent(accountId: String, completion: @escaping FetchStudentsCompletion)
    
    //
    //
    //
    func fetchLatestStudentInformation(count: Int, completion: @escaping FetchStudentsCompletion)
    
    //
    //
    //
    func addStudentInformation(student: StudentRequest, completion: @escaping UpdateStudentCompletion)
    
    //
    //
    //
    func updateStudentInformation(objectId: String, student: StudentRequest, completion: @escaping UpdateStudentCompletion)
}
