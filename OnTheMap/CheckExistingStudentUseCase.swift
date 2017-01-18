//
//  CheckExistingStudentUseCase.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct CheckExistingStudentUseCase {
    
    typealias Completion = (Result<Bool>) -> Void

    private let credentials = Credentials.shared
    
    let studentService: StudentService
    let completion: Completion
    
    func execute() {
        
        // Fetch current auth session.
        guard let session = credentials.session else {
            completion(.failure(ServiceError.authentication))
            return
        }
        
        // Fetch records for logged in student.
        studentService.fetchInformationForStudent(accountId: session.accountId) { (result) in
            switch result {
                
            // Error fetching entries for student.
            case .failure(let error):
                self.completion(Result.failure(error))
                
            // Fetched entries. Check if student has any entries.
            case .success(let entries):
                let hasLocation = (entries.count > 0)
                self.completion(Result.success(hasLocation))
            }
        }
    }
}
