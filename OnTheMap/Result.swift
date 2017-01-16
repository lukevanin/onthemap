//
//  Result.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
    
    init(value: T) {
        self = .success(value)
    }
    
    init(error: Error) {
        self = .failure(error)
    }
    
    func map<U>(_ f: (T) throws -> U) -> Result<U> {
        switch self {
        case .success(let t):
            do {
                let u = try f(t)
                return Result<U>.success(u)
            }
            catch {
                return Result<U>.failure(error)
            }
        case .failure(let error):
            return Result<U>.failure(error)
        }
    }
    
    func mapToVoid() -> Result<Void> {
        return map() { _ in
            return
        }
    }
}
