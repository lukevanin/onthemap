//
//  Result.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  General purpose container for API responses. This pattern ensures that value can only ever reference either an 
//  object an error, and avoids ambiguous states where both or neither are defined.
//
//  Also provides functional mapping, so that results can be easily transformed using simple functions, while avoiding 
//  the need to always handle the error condition. This loosely follows the monad pattern, originally from Haskell.
//
//  This is used in completion handlers, as an alternative to using the more conventional signature with separate 
//  response and error fields, and avoids the potential for ambiguous state (i.e. where both response and error are 
//  nil).
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
    
    //
    //  Convenience initializer to create a success state result.
    //
    init(value: T) {
        self = .success(value)
    }
    
    //
    //  Convenience initializer to create a failure state result.
    //
    init(error: Error) {
        self = .failure(error)
    }
    
    //
    //  Maps the result to a different type, by passing th value (if any) through a function. If the function throws an
    //  exception then the error is propogated to the result as a failure state. If the input result is already an 
    //  error then the function is not called and the input failure state is propogated to the output unmodified.
    //
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
    
    //
    //  Convenience method to map the result to a special Void result type. A void type carries no result data, although
    //  it serves the purpose of avoiding ambiguous state.
    //
    func mapToVoid() -> Result<Void> {
        return map() { _ in
            return
        }
    }
}
