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
        pinButtonItem.isEnabled = !state.isActive
        refreshButtonItem.isEnabled = !state.isActive
//        let leftBarButtonItems: [UIBarButtonItem] = [
//            state.isLoggingOut ? makeSpinner() : logoutButtonItem
//        ]
//        let rightBarButtonItems: [UIBarButtonItem] = [
//            state.isFetchingStudents ? makeSpinner() : refreshButtonItem,
//            state.isCheckingLocation ? makeSpinner() : pinButtonItem
//        ]
//        setLeftBarButtonItems(leftBarButtonItems, animated: true)
//        setRightBarButtonItems(rightBarButtonItems, animated: true)
    }
    
//    private func makeSpinner() -> UIBarButtonItem {
//        let view = UIActivityIndicatorView(activityIndicatorStyle: .white)
////        view.frame = CGRect(x: 0, y: 0, width: 54, height: 30)
//        view.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.startAnimating()
//        return UIBarButtonItem(customView: view)
//    }
}
