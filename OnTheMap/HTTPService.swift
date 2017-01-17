//
//  HTTPService.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  General purpose utility class for performing HTTP requests.
//

import Foundation

struct HTTPService {
    
    //
    //  Perform an HTTP/HTTPS request using the provided URL, method, headers, query, and body parameters. Only the URL
    //  is required, other fields will be used if present.
    //
    static func performRequest(url: URL, method: String = "GET", headers: [String: String]? = nil, query: [String: String]? = nil, parameters: [String: Any?]? = nil, completion: ((Result<Data>) -> Void)? = nil) {
        do {
            // Compose the request
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw ServiceError.request
            }
            
            // Add request query parameters.
            if let query = query {
                var queryItems = [URLQueryItem]()
                for (name, value) in query {
                    let queryItem = URLQueryItem(name: name, value: value)
                    queryItems.append(queryItem)
                }
                components.queryItems = queryItems
            }
            
            guard let requestURL = components.url else {
                throw ServiceError.request
            }
            
            // Instantiate the request. Set send and receive mime types to JSON.
            let request = NSMutableURLRequest(url: requestURL)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method
            
            // Set headers
            if let headers = headers {
                for (name, value) in headers {
                    request.setValue(value, forHTTPHeaderField: name)
                }
            }
            
            // Create request body with parameters
            if let parameters = parameters {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.httpBody = data
            }
            
            // Initiate the request
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                // Handle the error (if any).
                if let error = error {
                    completion?(Result.failure(error))
                    return
                }
                
                // Check response code. Return error for any code which is not 2xx.
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
                    let error: Error
                    switch httpResponse.statusCode {
                    case 401, 403:
                        error = ServiceError.authentication
                    case 400, 402, 404...499:
                        error = ServiceError.request
                    default:
                        error = ServiceError.server
                    }
                    completion?(Result.failure(error))
                    return
                }
                
                // Parse the response data.
                guard let data = data else {
                    let error = ServiceError.response
                    completion?(Result.failure(error))
                    return
                }
                
                completion?(Result.success(data))
            }
            task.resume()
        }
        catch {
            // Error creating request (ie serializing request parameters)
            completion?(Result.failure(ServiceError.request))
        }
    }
}
