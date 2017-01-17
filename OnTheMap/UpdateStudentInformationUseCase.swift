//
//  UpdateStudentInformationUseCase.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct UpdateStudentInformationUseCase {
    
    typealias Completion = (Bool, Error?) -> Void
    
    let location: StudentLocation
    let authentication: AuthenticationManager
    let studentService: StudentService
    let completion: Completion
    
    //
    //
    //
    func execute() {
        
        // Step 0: Fetch current authenticated session.
        authentication.fetchSession { result in
            
            switch result {
                
            // Fetched session.
            case .success(let session):
                // Fetch the current student
                self.fetchLocations(accountId: session.accountId)
                
            // Error fetching session.
            case .failure(let error):
                self.handleError(error)
            }
        }
        
    }
    
    // Step 1: Fetch existing location information for the student account.
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
    
    // Step 2: Fetch user information for the account. If a location already exists for the user then update it,
    // otherwise insert a new location.
    private func updateLocation(accountId: String, existingLocations: [StudentInformation]) {
        authentication.fetchUser(accountId: accountId) {  result in
            switch result {
            case .success(let user):
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
    
    // Step 3: Handle the response for adding or updating a location.
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
