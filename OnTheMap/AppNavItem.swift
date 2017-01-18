//
//  AppNavBar.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  A navigation item which enabled and disables navigation bar items depending on app state. Used on the map and list
//  view controllers. Disabling buttons while with showing a status bar activity indicator, visually indicates to the
//  user that an action is in progress and prevents duplicate successive actions.
//
//  Technically not a view.
//

import UIKit

class AppNavItem: UINavigationItem {
    
    @IBOutlet var logoutButtonItem: UIBarButtonItem!
    @IBOutlet var pinButtonItem: UIBarButtonItem!
    @IBOutlet var refreshButtonItem: UIBarButtonItem!
    
    var state: AppState? {
        didSet {
            updateState(animated: true)
        }
    }
    
    private func updateState(animated: Bool) {
        
        guard let state = self.state else {
            return
        }
        
        // Disable the login button during any action. Avoids actions initiated before logout from completing after the 
        // login view becomes visible.
        logoutButtonItem.isEnabled = !state.isActive
        
        // Disable the pin button if logging out and while checking the student's location.
        pinButtonItem.isEnabled = !state.isLoggingOut && !state.isCheckingLocation
        
        // Disable the refresh button while logging out and while loading students.
        refreshButtonItem.isEnabled = !state.isLoggingOut && !state.isFetchingStudents
    }
}
