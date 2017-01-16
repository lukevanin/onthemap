//
//  ConcreteStudentService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct UdacityStudentService: StudentService {
    
    let baseURL = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
    let headers = [
        "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
        "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    ]

    //
    //
    //
    func fetchInformationForStudent(accountId: String, completion: @escaping FetchStudentsCompletion) {
        let query = [
            "where": "{\"uniqueKey\": \"\(accountId)\"}"
        ]
        fetchStudents(query: query, completion: completion)
    }
    
    //
    //
    //
    func fetchLatestStudentInformation(count: Int, completion: @escaping FetchStudentsCompletion) {
        let query = [
            "limit": "100",
            "order": "-updatedAt"
        ]
        fetchStudents(query: query, completion: completion)
    }
    
    //
    //
    //
    private func fetchStudents(query: [String: String], completion: @escaping FetchStudentsCompletion) {
        HTTPService.performRequest(
            url: baseURL,
            method: "GET",
            headers: headers,
            query: query,
            completion: { result in
                let output = result.map(self.parseStudents)
                completion(output)
        })
    }
    
    //
    //
    //
    func addStudentInformation(student: StudentRequest, completion: @escaping UpdateStudentCompletion) {
        submitStudent(
            url: baseURL,
            method: "POST",
            student: student,
            completion: completion
        )
    }
    
    //
    //
    //
    func updateStudentInformation(objectId: String, student: StudentRequest, completion: @escaping UpdateStudentCompletion) {
        submitStudent(
            url: baseURL.appendingPathComponent(objectId),
            method: "PUT",
            student: student,
            completion: completion
        )
    }
    
    //
    //
    //
    private func submitStudent(url: URL, method: String, student: StudentRequest, completion: @escaping UpdateStudentCompletion) {
        let json = student.toJSON()
        HTTPService.performRequest(
            url: url,
            method: method,
            headers: headers,
            parameters: json,
            completion: { result in
                completion(result.mapToVoid())
        })
    }
    
    // MARK: Parsing

    //
    //
    //
    private func parseStudents(_ data: Data) throws -> [StudentInformation] {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let container = json as? [String: Any] else {
            throw JSONError.format("dictionary")
        }
        
        guard let entities = container["results"] as? [Any] else {
            throw JSONError.format("array")
        }
        
        var students = [StudentInformation]()
        
        for entity in entities {
            if let student = try? StudentInformation(json: entity) {
                students.append(student)
            }
        }
        
        return students
    }
}
