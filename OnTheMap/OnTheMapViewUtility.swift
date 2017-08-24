//
//  OnTheMapViewUtility.swift
//  OnTheMap
//
//  Created by Lisue She on 6/2/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import MapKit
import Foundation


class OnTheMapViewUtility: UIViewController  {
    
    func goToStudentURL(studentURL: String?) -> UIAlertController? {
       
        guard let studentLink=studentURL, studentLink.characters.count>0  else {
            return errorAlertView(title: "Waring", message: "Invalid Student URL")
        }
       
        guard let url = URL(string: studentLink) else {
            return errorAlertView(title: "Waring", message: "Invalid Student URL")
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil
        } else {
            print("Cannot Open Student URL")
            return errorAlertView(title: "Waring", message: "Cannot Open Student URL")
        }
    }
    
    func onTheMapLogout(_ sender: Any, from: UIViewController) {
        UdacityAuthentication.sharedInstance.udacitySessionLogout() { (error) in
            guard error==nil else {
               return
            }
            
            DispatchQueue.main.async {
                from.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func errorAlertView(title: String, message: String) -> UIAlertController {
        print("message at errorAlertView: \(message)")
        let invalidURLAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        invalidURLAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        return invalidURLAlert
    }
    
    func showActivityIndicator(uiView: UIView) -> UIActivityIndicatorView {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        return actInd
    }
    
    static let sharedInstance = OnTheMapViewUtility()
}


class onTheMapTextFieldDelegate: NSObject, UITextFieldDelegate, MKMapViewDelegate {
    var currentView = UIView()
    var keyboardOnScreen = false
    var hiddenType = HiddenElement.udacityLogo
    var hiddenElement: AnyObject?=nil
    

    func textFieldInitial(currentView: UIView, hiddenType: HiddenElement, hiddenElement: AnyObject) {
        self.currentView = currentView
        self.hiddenType = hiddenType
        self.hiddenElement = hiddenElement
    
        subscribeNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen && !(hiddenType==HiddenElement.linkPrompt) {
            currentView.frame.origin.y -= keyboardHeight(notification)
            switchHiddenElement(isHidden: true)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen && !(hiddenType==HiddenElement.linkPrompt) {
            currentView.frame.origin.y += keyboardHeight(notification)
            switchHiddenElement(isHidden: false)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
        
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }

    private func switchHiddenElement(isHidden: Bool) {
        switch (hiddenType) {
        case .udacityLogo:
            let nowHidden = hiddenElement as! UIImageView
            nowHidden.isHidden = isHidden
        case .addressPrompt:
            let nowHidden = hiddenElement as! UILabel
            nowHidden.isHidden = isHidden
        case .linkPrompt:
            break
        }
        
    }
    
    func subscribeNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeAllNotification() {
        NotificationCenter.default.removeObserver(self)
    }
}

