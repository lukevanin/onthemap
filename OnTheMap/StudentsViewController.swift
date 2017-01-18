//
//  StudentsViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

open class StudentsViewController: UIViewController {
    
    var delegate: StudentsControllerDelegate?
    
    let appState = AppState.shared
    let model = StudentsModel.shared
    
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
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBar()
        updateContent()
        addNotificationObservers()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }
    
    // MARK: Notifications
    
    //
    //  Observe changes to the model.
    //
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStudentsModelChanged), name: .StudentsModelChanged, object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(onAppStateChanged), name: .AppStateChanged, object: appState)
    }
    
    //
    //  Stop observing changes to the model.
    //
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .StudentsModelChanged, object: model)
        NotificationCenter.default.removeObserver(self, name: .AppStateChanged, object: model)
        
    }
    
    //
    //  Reload the table when the model changes.
    //
    @objc func onStudentsModelChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.updateContent()
        }
    }
    
    //
    //  Update the navigation bar when the app state changes.
    //
    @objc func onAppStateChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.updateNavBar()
        }
    }
    
    //
    //
    //
    private func updateNavBar() {
        if let navigationItem = navigationItem as? AppNavItem {
            navigationItem.state = appState
        }
    }

    // MARK: Overrides
    
    open func updateContent() {
        
    }
}
