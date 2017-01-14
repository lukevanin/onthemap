//
//  MockStudentService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class MockStudentService: StudentService {
    
    enum StudentError: Error {
        case mismatch
    }
    
    private var students = [
        StudentInformation(
            objectId: "JhOtcRkxsh",
            uniqueKey: "996618664",
            user: User(
                firstName: "Jarrod",
                lastName: "Parkes"
                ),
            location: StudentLocation(
                mapString: "Huntsville, Alabama",
                mediaURL: "https://www.linkedin.com/in/jarrodparkes",
                longitude: -86.5861037,
                latitude: 34.7303688
                )
        ),
        
        StudentInformation(
            objectId: "kj18GEaWD8",
            uniqueKey: "872458750",
            user: User(
                firstName: "Jessica",
                lastName: "Uelmen"
                ),
            location: StudentLocation(
                mapString: "Tarpon Springs, FL",
                mediaURL: "www.linkedin.com/in/jessicauelmen/en",
                longitude: -82.756768,
                latitude: 28.1461248
            )
        )
        
//        StudentInformation(
//            objectId: "hiz0vOTmrL",
//            uniqueKey: "2362758535",
//            firstName: "Jason",
//            lastName: "Schatz",
//            mapString: "18th and Valencia, San Francisco, CA",
//            mediaURL: "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
//            latitude: 37.7617,
//            longitude: -122.4216
//        ),
//        
//        StudentInformation(
//            objectId: "8ZEuHF5uX8",
//            uniqueKey: "2256298598",
//            firstName: "Gabrielle",
//            lastName: "Miller-Messner",
//            mapString: "Southern Pines, NC",
//            mediaURL: "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
//            latitude: 35.1740471,
//            longitude: -79.3922539
//        )

    ]
    
    func fetchInformationForStudent(accountId: String, completion: @escaping FetchStudentsCompletion) {
        let matches = students.filter() { $0.uniqueKey == accountId }
        completion(Result.success(matches))
    }
    
    func fetchLatestStudentInformation(count: Int, completion: @escaping FetchStudentsCompletion) {
        completion(.success(students))
    }
    
    func addStudentInformation(student: StudentRequest, completion: @escaping UpdateStudentCompletion) {
        let information = makeStudentInformation(objectId: makeRandomObjectId(), request: student)
        students.append(information)
        completion(.success())
    }
    
    func updateStudentInformation(objectId: String, student: StudentRequest, completion: @escaping UpdateStudentCompletion) {

        // Get index of match
        let match = students.index() { $0.objectId == objectId }
        
        guard let index = match else {
            // No matches
            completion(.failure(StudentError.mismatch))
            return
        }
        
        let information = makeStudentInformation(objectId: objectId, request: student)
        students[index] = information
        completion(.success())
    }
    
    private func makeRandomObjectId() -> String {
        let characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".characters
        var output = ""
        for _ in 0 ..< 10 {
            let offset = Int(arc4random()) % Int(characters.count)
            let index = characters.index(characters.startIndex, offsetBy: offset)
            let character = characters[index]
            output.append(character)
        }
        return output
    }

    private func makeStudentInformation(objectId: String, request: StudentRequest) -> StudentInformation {
        return StudentInformation(
            objectId: objectId,
            uniqueKey: request.uniqueKey,
            user: request.user,
            location: request.location
        )
    }
}
