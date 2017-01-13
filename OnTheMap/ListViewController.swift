//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, StudentsController {
    
    var model: [StudentInformation]?
    var delegate: StudentsControllerDelegate?
    var viewController: UIViewController {
        return self
    }

    private let cellIdentifier = "UserCell"
    
    // MARK: Actions
    
    @IBAction func onLogoutAction(_ sender: Any) {
        delegate?.studentsController(controller: self, action: .logout, sender: sender)
    }
    
    @IBAction func onPinAction(_ sender: Any) {
        delegate?.studentsController(controller: self, action: .addLocation, sender: sender)
    }
    
    @IBAction func onRefreshAction(_ sender: Any) {
        delegate?.studentsController(controller: self, action: .refresh, sender: sender)
    }

    // MARK: View controller life cycle
    
}
