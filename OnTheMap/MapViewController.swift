//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Display locations of students on a zoomable, scrollable map. Tapping a pin shows a callout with the student's name
//  and media URL (if present). Tapping the callout opens the media URL in a browser. Delegates data and actions to an 
//  external object.
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
    //  Update the annotations on the map. An annotation is created for each student location in the model. The 
    //  annotation contains data for the coordinates of where the pin should appear, as well as the name and URL to 
    //  show when the pin is tapped. The annotation is used to instantiate a view for the pin (see MKMapViewDelegate
    //  below).
    //
    private func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        if let annotations = makeAnnotations() {
            mapView.addAnnotations(annotations)
        }
    }
    
    //
    //  Creates any array annotations from the model containing student information entries.
    //
    private func makeAnnotations() -> [MKAnnotation]? {
        return model?.map(makeAnnotationForStudent)
    }
    
    //
    //  Creates a single annotation for a student information entity.
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
//  Extension for the MapViewController to control rendering and interactions for map pins.
//
extension MapViewController: MKMapViewDelegate {
    
    //
    //  Create a view for a given annotation. Uses a recycled view from the pool if available. An info ⓘ button is 
    //  displayed on the annotation if the student information associated with the annotation has a valid URL.
    //
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "StudentAnnotation"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            view?.canShowCallout = true
            
            if let studentAnnotation = annotation as? StudentAnnotation, let info = studentAnnotation.student, info.location.hasValidURL {
                let infoButton = UIButton(type: .infoLight)
                infoButton.tintColor = UIColor(hue: 30.0 / 360.0, saturation: 1.0, brightness: 1.0, alpha: 1.00)
                view?.rightCalloutAccessoryView = infoButton
            }
            else {
                view?.rightCalloutAccessoryView = nil
            }
        }
        
        return view
    }
    
    //
    //  Handles user tapping on the annotation view. Opens the user's media URL in a browser.
    //
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? StudentAnnotation, let info = annotation.student else {
            return
        }
        delegate?.showInformationForStudent(info)
    }
}
