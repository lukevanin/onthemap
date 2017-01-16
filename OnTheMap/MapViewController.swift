//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, StudentsController {
    
    class StudentAnnotation: MKPointAnnotation {
        var student: StudentInformation?
    }
    
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
                self.updateMap()
            }
        }
    }
    var delegate: StudentsControllerDelegate?
    
    // MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    
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
        updateMap()
    }
    
    private func updateState() {
        if let appNavItem = navigationItem as? AppNavItem {
            appNavItem.state = state
        }
    }
    
    // MARK: Pins
    
    //
    //
    //
    private func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        if let annotations = makeAnnotations() {
            mapView.addAnnotations(annotations)
        }
    }
    
    //
    //
    //
    private func makeAnnotations() -> [MKAnnotation]? {
        return model?.map(makeAnnotationForStudent)
    }
    
    //
    //
    //
    private func makeAnnotationForStudent(info: StudentInformation) -> StudentAnnotation {
        let output = StudentAnnotation()
        output.student = info
        output.coordinate = CLLocationCoordinate2D(latitude: info.location.latitude, longitude: info.location.longitude)
        output.title = info.user.firstName + " " + info.user.lastName
        output.subtitle = info.location.validURL?.absoluteString ?? nil
        return output
    }
}

//
//
//
extension MapViewController: MKMapViewDelegate {
    
    //
    //
    //
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "StudentAnnotation"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            view?.canShowCallout = true
            
            let infoButton = UIButton(type: .infoLight)
            infoButton.tintColor = UIColor(hue: 30.0 / 360.0, saturation: 1.0, brightness: 1.0, alpha: 1.00)
            view?.rightCalloutAccessoryView = infoButton
        }
        
        return view
    }
    
    //
    //
    //
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? StudentAnnotation, let info = annotation.student else {
            return
        }
        delegate?.showInformationForStudent(info)
    }
}
