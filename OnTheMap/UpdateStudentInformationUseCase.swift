//
//  UpdateStudentInformationUseCase.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Encapsulates logic for updating information for a student. The process is:
//
//      1. Fetch the credentials for the current login session to obtain the account ID.
//      2. Fetch the locations for the student with the account ID from step 1.
//      3a. If one or more entries already exist for the student, then use the object ID from the first location.
//      3b. If no entries exist then insert a new entry.
//

import Foundation

struct UpdateStudentInformationUseCase {
    
    typealias Completion = (Bool, Error?) -> Void

    private let credentials = Credentials.shared

    let location: StudentLocation
    let userService: UserService
    let studentService: StudentService
    let completion: Completion
    
    //
    //  Step 0: Fetch current authenticated session.
    //
    func execute() {

        guard let session = credentials.session else {
            handleError(ServiceError.authentication)
            return
        }
        
        self.fetchLocations(accountId: session.accountId)
    }
    
    //
    //  Step 1: Fetch existing location information for the student account.
    //
    private func fetchLocations(accountId: String) {
        studentService.fetchInformationForStudent(accountId: accountId) { (result) in
            switch result {
            case .success(let locations):
                self.updateLocation(accountId: accountId, existingLocations: locations)
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    //
    // Step 2 and 3: Fetch user information for the account. If a location already exists for the user then update it,
    // otherwise insert a new location.
    //
    private func updateLocation(accountId: String, existingLocations: [StudentInformation]) {
        userService.fetchUser(accountId: accountId) { (result) in
            switch result {
            
            case .success(let user):
                // Successfully fetched user for account ID. 
                // Update or insert the location for the student.
                let request = StudentRequest(
                    uniqueKey: accountId,
                    user: user,
                    location: self.location
                )
                
                if let location = existingLocations.first {
                    self.studentService.updateStudentInformation(
                        objectId: location.objectId,
                        student: request,
                        completion: self.handleUpdateResult
                    )
                }
                else {
                    self.studentService.addStudentInformation(
                        student: request,
                        completion: self.handleUpdateResult
                    )
                }
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    // Handle the response for adding or updating a location.
    private func handleUpdateResult(_ result: Result<Void>) {
        
        switch result {
        case .success:
            // Location saved
            completion(true, nil)
            
        case .failure(let error):
            handleError(error)
        }
    }

    // Handle error
    private func handleError(_ error: Error) {
        completion(false, error)
    }

}
