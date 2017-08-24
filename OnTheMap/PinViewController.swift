//
//  PinViewController.swift
//  OnTheMap
//
//  Created by Lisue She on 6/3/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit

import MapKit

class PinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate{
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var location = false
    
    @IBOutlet weak var promptLable: UILabel!
    @IBOutlet weak var textPrompt: UITextField!
   
    @IBOutlet weak var linkPrompt: UITextField!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var findMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    let textFieldDelegate = onTheMapTextFieldDelegate()
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        mapView.delegate = self
        
        textPrompt.delegate = textFieldDelegate
        linkPrompt.delegate = textFieldDelegate
        textFieldDelegate.textFieldInitial(currentView: view, hiddenType: .addressPrompt, hiddenElement: promptLable)
        
        promptLable.numberOfLines = 0
        promptLable.text="Where are you\nStudying\ntoday?"
        textPrompt.text="City, State"
        self.viewSwitchSetup(addressViewOff: false, mapViewOff: true)
        pinProfileActionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldDelegate.unsubscribeAllNotification()
    }
    
    @IBAction func findMapButtonPressed(_ sender: Any) {
        let geocoder = CLGeocoder()
        actInd = OnTheMapViewUtility.sharedInstance.showActivityIndicator(uiView: view)
        DispatchQueue.main.async {
            self.view.addSubview(self.actInd)
            self.actInd.startAnimating()
        }

        geocoder.geocodeAddressString(self.textPrompt.text!) { (placemark, error) in
            self.actInd.stopAnimating()
            
            if error != nil {
                performUIUpdatesOnMain {
                    self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:"ERROR",message:"Location Is Not Valid"), animated: true, completion: nil)
                }
                return
            }
            
            guard let placemark = placemark?[0] else { return }
            if let locationText = self.textPrompt.text {
                StudentDataSource.sharedInstance.pinStudent.mapString = locationText
            }
                StudentDataSource.sharedInstance.pinStudent.latitude = placemark.location!.coordinate.latitude
                StudentDataSource.sharedInstance.pinStudent.longitude = placemark.location!.coordinate.longitude
            self.textFieldDelegate.textFieldShouldReturn(self.textPrompt)
            self.viewSwitchSetup(addressViewOff: true, mapViewOff: false)
            self.centerMapOnLocation(latitude: StudentDataSource.sharedInstance.pinStudent.latitude, longitude: StudentDataSource.sharedInstance.pinStudent.longitude)
            self.textFieldDelegate.hiddenType = .linkPrompt
            self.textFieldDelegate.hiddenElement = self.mapView
        }
    }
   
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let linkURL = self.linkPrompt.text
        var linkError = false
        
        if self.linkPrompt.text!.isEmpty || self.linkPrompt.text!=="Add Profile Link" {
            linkError = true
        } else if !UIApplication.shared.canOpenURL(URL(string: linkURL!)!) {
            linkError = true
        } else {
            StudentDataSource.sharedInstance.pinStudent.mediaURL = self.linkPrompt.text!
            OnTheMapStudentData.sharedInstance.postStudentLocationData(studentData: StudentDataSource.sharedInstance.pinStudent) { (error) in
                guard error==nil else {
                    performUIUpdatesOnMain {
                        self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:"ERROR",message:"Failed to update pin"), animated: true, completion: nil)
                    }
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        performUIUpdatesOnMain {
            self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:"ERROR",message:"URL Is Not Valid"), animated: true, completion: nil)
        }
        return
    }
    
  
    
    @IBAction func cancelPinAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewSwitchSetup(addressViewOff: Bool, mapViewOff: Bool) {
        linkPrompt.isHidden = mapViewOff
        mapView.isHidden = mapViewOff
        submitButton.isHidden = mapViewOff
        
        findMapButton.isHidden = addressViewOff
        promptLable.isHidden = addressViewOff
        textPrompt.isHidden = addressViewOff
    }

    func centerMapOnLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }

    func pinProfileActionView() -> Void {
        let title="Posting Pin Options"
        let message = "Please select your options\nIf you are new to post a pin, please press new button, otherwise, press update"
        print("pinProfileAction: \(message)")
        let pinUpdateURLAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        pinUpdateURLAlert.addAction(UIAlertAction(title: "New", style: UIAlertActionStyle.default) { (pinUpdateURLAlert:UIAlertAction) in
            self.pinStudentStatusCheck(isNew:true)
            })
        pinUpdateURLAlert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default) { (pinUpdateURLAlert:UIAlertAction) in
                self.pinStudentStatusCheck(isNew:false)
        })
        performUIUpdatesOnMain {
                self.present(pinUpdateURLAlert, animated: true, completion: nil)
        }
    }
    
    func pinStudentStatusCheck(isNew:Bool) {
        let studentKey = appDelegate.accountKey
    
        OnTheMapStudentData.sharedInstance.getStudentLocationData(withKey: studentKey) { (studentData) in
            guard let student=studentData else {
                self.appDelegate.pinIsNew = true
                StudentDataSource.sharedInstance.pinStudent.uniqueKey = self.appDelegate.accountKey
                StudentDataSource.sharedInstance.pinStudent.firstName = self.appDelegate.first_name
                StudentDataSource.sharedInstance.pinStudent.lastName = self.appDelegate.last_name
            
                if !isNew {
                    performUIUpdatesOnMain {
                        self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:"WARNING",message:"Student's pin doesn't exist. Pin will be created with the information given."), animated: true, completion: nil)
                    }
                }
                return
            }
                    
           
            self.appDelegate.pinIsNew = false
            StudentDataSource.sharedInstance.pinStudent = student[0]
            self.linkPrompt.text = student[0].mediaURL
            if isNew {
                performUIUpdatesOnMain {
                    self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:"WARNING",message:"Student's pin already exists. Information given will be updated to the existing pin"), animated: true, completion: nil)
                }
            }
        }
    }
}
