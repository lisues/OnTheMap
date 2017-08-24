//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Lisue She on 5/29/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    var annotations = [MKPointAnnotation]()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        displayStudentAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func displayStudentAnnotations() {
        setStudentDataAnnotations() { (result) in
            if result {
                performUIUpdatesOnMain {
                    self.mapView.addAnnotations(self.annotations)
                }
            } else {
                performUIUpdatesOnMain {
                    let title="Warning"
                    self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:title,message:"No Student Data Available"), animated: true, completion: nil)
                }
            }
        }
    }
    
    func setStudentDataAnnotations(completionHandlerStudentAnnotation: @escaping (_ success: Bool) -> Void) {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        OnTheMapStudentData.sharedInstance.getStudentLocationData(withKey: nil) { (studentData) in
            if let studentData=studentData {
                for studentInfo in studentData {
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentInfo.latitude), longitude: CLLocationDegrees(studentInfo.longitude))
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(studentInfo.firstName) \(studentInfo.lastName)"
                    annotation.subtitle = studentInfo.mediaURL
                    self.annotations.append(annotation)
                
                    StudentDataSource.sharedInstance.studentData.append(studentInfo)
                }
                completionHandlerStudentAnnotation(true)
                return
            }
            completionHandlerStudentAnnotation(false)
        }
    }
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                if let alertControl = OnTheMapViewUtility.sharedInstance.goToStudentURL(studentURL: toOpen) {
                    performUIUpdatesOnMain {
                        self.present(alertControl, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func mapLogout(_ sender: Any) {
        print("at Map View Logout")
        OnTheMapViewUtility.sharedInstance.onTheMapLogout(sender, from: self)
    }
   
    
    @IBAction func mapRefresh(_ sender: Any) {
        self.mapView.removeAnnotations(self.annotations)
        displayStudentAnnotations()
    }
}

