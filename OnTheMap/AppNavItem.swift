//
//  AppNavBar.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class AppNavItem: UINavigationItem {
    
    @IBOutlet var logoutButtonItem: UIBarButtonItem!
    @IBOutlet var pinButtonItem: UIBarButtonItem!
    @IBOutlet var refreshButtonItem: UIBarButtonItem!
    
    var state = AppState() {
        didSet {
            updateState(animated: true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateState(animated: false)
    }
    
    private func updateState(animated: Bool) {
        logoutButtonItem.isEnabled = !state.isActive
        pinButtonItem.isEnabled = !state.isLoggingOut && !state.isCheckingLocation
        refreshButtonItem.isEnabled = !state.isLoggingOut && !state.isFetchingStudents
    }
}
