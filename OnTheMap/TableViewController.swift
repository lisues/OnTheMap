//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Lisue She on 5/31/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    let studentObj = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentDataSource.sharedInstance.studentData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "onTheMapStudentData")!
        let studentInfo = StudentDataSource.sharedInstance.studentData[(indexPath as NSIndexPath).row]
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
     
        return cell
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stdentInfo = StudentDataSource.sharedInstance.studentData[(indexPath as NSIndexPath).row]
        if let alertControl = OnTheMapViewUtility.sharedInstance.goToStudentURL(studentURL: stdentInfo.mediaURL) {
            performUIUpdatesOnMain {
                self.present(alertControl, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func tableLogout(_ sender: Any) {
         OnTheMapViewUtility.sharedInstance.onTheMapLogout(sender, from: self)
    }
    
    @IBAction func tableRefresh(_ sender: Any) {
        OnTheMapStudentData.sharedInstance.getStudentLocationData(withKey:nil) { (studentData) in
            print("get fresh student data")
            if let studentData = studentData {
                StudentDataSource.sharedInstance.studentData = studentData
                performUIUpdatesOnMain {
                    self.tableView?.reloadData()
                }                
            }
        }
    }
}
