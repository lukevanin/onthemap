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

class ListViewController: StudentsViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "UserCell"
    
    // MARK: View controller life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }
    
    // MARK: Table view
    
    override func updateContent() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Update the table cell with the student information. Shows a detail disclosure indicator if the media URL is 
        // valid.
        let info = model.students[indexPath.row]
        cell.textLabel?.text = info.user.firstName + " " + info.user.lastName
        cell.detailTextLabel?.text = info.location.hasValidURL ? info.location.mapString : nil
        cell.accessoryType = info.location.hasValidURL ? .disclosureIndicator : .none
        
        return cell
    }
    
    //
    //  Called when the user taps on a student entry. Opens the media URL in a browser window.
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = model.students[indexPath.row]
        delegate?.showInformationForStudent(info)
    }
}
