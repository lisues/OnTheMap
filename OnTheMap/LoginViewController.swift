//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Lisue She on 5/26/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIAlertViewDelegate {

    @IBOutlet weak var udacityLogo: UIImageView!
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    let textFieldDelegate = onTheMapTextFieldDelegate()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        username.delegate = textFieldDelegate
        password.delegate = textFieldDelegate
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFieldDelegate.textFieldInitial(currentView: view, hiddenType: .udacityLogo, hiddenElement: udacityLogo)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldDelegate.unsubscribeAllNotification()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let title = "Login Error"
                
        guard !(username.text!.isEmpty || password.text!.isEmpty) else {
            print("Username or Password Empty.")
            self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:title, message:"Username or Password Empty."), animated: true, completion: nil)
            
            return
        }
    
        activityIndicator = OnTheMapViewUtility.sharedInstance.showActivityIndicator(uiView: view)
        DispatchQueue.main.async {
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
        UdacityAuthentication.sharedInstance.udacityLogin(userName: username.text!, password: password.text!) { (error) in
            self.activityIndicator.stopAnimating()
            if let error=error {
                print("Cannot Login")
                let userInfo = error.userInfo[NSLocalizedDescriptionKey]
                let message = userInfo as! String
                performUIUpdatesOnMain {
                    self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:title,message:message), animated: true, completion: nil)
                }
                return
            }
                
            self.completeLogin()
        }
    }

    
    
    @IBAction func udacitySignIn(_ sender: Any) {
        let url = URL(string: "https://udacity.com")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func signInWithFacebook(_ sender: Any) {
        performUIUpdatesOnMain {
            self.present(OnTheMapViewUtility.sharedInstance.errorAlertView(title:"Message",message:"Facebook login is not available at this time."), animated: true, completion: nil)
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.username.text=""
            self.password.text=""
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "onTheMapTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
}

