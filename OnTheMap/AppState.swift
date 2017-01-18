//
//  AppState.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Contains the state of the application. Updated by the StudentsAppController. Used by AppNavItem to enabled and 
//  disable UI controls according to current state.
//

import Foundation

extension NSNotification.Name {
    static let AppStateChanged = NSNotification.Name(rawValue: "AppStateChanged")
}

class AppState {
    
    //
    //  Shared singleton instance. Used in the StudentsAppController, and AppNavItem. 
    //
    static var shared = AppState()
    
    //
    //  App is busy logging out.
    //
    var isLoggingOut: Bool {
        didSet {
            self.notify()
        }
    }
    
    //
    //  App is busy fetching list of students from web service API.
    //
    var isFetchingStudents: Bool {
        didSet {
            self.notify()
        }
    }

    //
    //  App is busy checking if the user has already uploaded location information.
    //
    var isCheckingLocation: Bool {
        didSet {
            self.notify()
        }
    }
    
    //
    //  App is busy performing one or more activities.
    //
    var isActive: Bool {
        // Returns true if any of the behaviors are active.
        return isLoggingOut || isFetchingStudents || isCheckingLocation
    }
    
    //
    //  Initialize the default state with all activities inactive.
    //
    init() {
        self.isLoggingOut = false
        self.isFetchingStudents = false
        self.isCheckingLocation = false
    }
    
    //
    //  Post notification when app state changes.
    //
    private func notify() {
        NotificationCenter.default.post(name: .AppStateChanged, object: self)
    }
}
