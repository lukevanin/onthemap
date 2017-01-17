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
    
    let studentService: StudentService
    let authentication: AuthenticationManager
    let completion: Completion
    
    //
    //
    //
    func execute() {
        // Fetch current auth session.
        authentication.fetchSession { result in
            switch result {
                
            // Error fetching session.
            case .failure(let error):
                self.completion(Result.failure(error))
                
            // Fetched sesion. Fetch locations for user.
            case .success(let session):
                self.studentService.fetchInformationForStudent(accountId: session.accountId) { (result) in
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
    }
}
