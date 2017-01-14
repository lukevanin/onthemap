//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, StudentsController {
    
    var model: [StudentInformation]? {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }
    
    var delegate: StudentsControllerDelegate?
    var viewController: UIViewController {
        return self
    }
    
    private let cellIdentifier = "UserCell"
//    private let pinImage = UIImage(named: "pin").templ
    
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

    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if let info = model?[indexPath.row] {
            cell.textLabel?.text = info.user.firstName + " " + info.user.lastName
            cell.detailTextLabel?.text = info.location.mapString
        }
        
        return cell
    }
    
    //
    //
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let info = model?[indexPath.row] else {
            return
        }
        delegate?.studentsController(controller: self, action: .showInformation(info), sender: nil)
    }
}
