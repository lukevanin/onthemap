//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Lists student location information in a table view. Tapping on a cell opens the media URL in a browser.
//

import UIKit

class ListViewController: UITableViewController, StudentsController {

    var state = AppState() {
        didSet {
            if self.isViewLoaded {
                self.updateState()
            }
        }
    }

    var model: [StudentInformation]? {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }
    
    var delegate: StudentsControllerDelegate?
    
    private let cellIdentifier = "UserCell"
    
    // MARK: Actions
    
    @IBAction func onLogoutAction(_ sender: Any) {
        delegate?.logout()
    }
    
    @IBAction func onPinAction(_ sender: Any) {
        delegate?.addLocation()
    }
    
    @IBAction func onRefreshAction(_ sender: Any) {
        delegate?.loadStudents()
    }

    // MARK: View controller life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }
    
    private func updateState() {
        if let appNavItem = navigationItem as? AppNavItem {
            appNavItem.state = state
        }
    }

    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Update the table cell with the student information. Shows a detail disclosure indicator if the media URL is 
        // valid.
        if let info = model?[indexPath.row] {
            cell.textLabel?.text = info.user.firstName + " " + info.user.lastName
            cell.detailTextLabel?.text = info.location.hasValidURL ? info.location.mapString : nil
            cell.accessoryType = info.location.hasValidURL ? .disclosureIndicator : .none
        }
        
        return cell
    }
    
    //
    //  Called when the user taps on a student entry. Opens the media URL in a browser window.
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let info = model?[indexPath.row] else {
            return
        }
        delegate?.showInformationForStudent(info)
    }
}
