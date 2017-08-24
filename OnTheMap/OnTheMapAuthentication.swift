//
//  OnTheMapAuthentication.swift
//  OnTheMap
//
//  Created by Lisue She on 6/10/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import Foundation

class UdacityAuthentication {
    func udacityLogin(userName: String, password: String, completionHandlerUdaciatyLogin: @escaping (_ error: NSError?) -> Void)  {
        let parameters=[String: AnyObject]()
        let addHeaderField = ["Accept": "application/json",
                              "Content-Type": "application/json"]
        let jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
    
        OnTheMapClient.sharedInstance().taskRequest(.udacityPOST, Constants.OnTheMapApi.UdacitySession, addHeaderField:addHeaderField, setHeaderField:nil, parameters:parameters, jsonBody: jsonBody) { (data, error) in
            if let error=error {
                completionHandlerUdaciatyLogin(error)
                return
            }
        
            self.getUdacityUserAuthentication(data:data) { (error) in
                completionHandlerUdaciatyLogin(error)
            }
        }
    }

    func getUdacityUserAuthentication(data: Data?, completionHandlerUserSetup: @escaping (_ error: NSError?) -> Void) {

        var appDelegate: AppDelegate!
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        let range = Range(5..<data!.count)
        let newData = data?.subdata(in: range) /* subset response data! */
        let parsedData:[String:AnyObject]!
        do {
            parsedData = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String: AnyObject]
            print(parsedData)
            if let userAccount=parsedData["account"] as? [String:AnyObject], let accountKey=userAccount["key"] as? String {
                appDelegate.accountKey = accountKey
            }
            
            if let userSession=parsedData["session"] as? [String:AnyObject], let sessionId=userSession["id"] as? String {
                appDelegate.sessionId = sessionId
            }
            
            getUdacityUserData(userKey: appDelegate.accountKey) { (result) in
                if let result=result {
                    completionHandlerUserSetup(result)
                } else {
                    completionHandlerUserSetup(nil)
                }
                return
            }
        } catch {
            print("Error on parsing data")
            let userInfo = [NSLocalizedDescriptionKey : "Error on parsing data"]
            completionHandlerUserSetup(NSError(domain: "OnTheMapUdacityUserSetup", code: LoginError.generalError, userInfo: userInfo))
            return
        }
    }
    
    func getUdacityUserData(userKey: String, completionHandlerUserData: @escaping (_ error: NSError?) -> Void) {
        var appDelegate: AppDelegate!
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let parameters=[String: AnyObject]()
        let method = "\(Constants.OnTheMapApi.UdacityUser)\(userKey)"
        OnTheMapClient.sharedInstance().taskRequest(.udacityGET, method, addHeaderField:nil, setHeaderField:nil, parameters:parameters, jsonBody: nil) { (data, error) in
            if let error=error {
                completionHandlerUserData(error)
                return
            } else {
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                let parsedData:[String:AnyObject]!
                do {
                    parsedData = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String: AnyObject]

                    if let user = parsedData["user"] as? [String:AnyObject] {
                        if let firstName = user["first_name"] as? String{
                            appDelegate.first_name = firstName
                        }
                        
                        if let lastName = user["last_name"] as? String{
                            appDelegate.last_name = lastName
                        }
                    }
                } catch {
                    print("Error on parsing data")
                    let userInfo = [NSLocalizedDescriptionKey : "Error on parsing data"]
                    completionHandlerUserData(NSError(domain: "getUserData", code: LoginError.generalError, userInfo: userInfo))
                    return
                }
                completionHandlerUserData(nil)
            }
        }
    }
  
    func udacitySessionLogout(completionHandlerSessionLogout: @escaping (_ error: NSError?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.OnTheMapApi.UdacitySession)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                print("issue with session logout")
                let userInfo = [NSLocalizedDescriptionKey : "issue with session logout"]
                completionHandlerSessionLogout(NSError(domain: "session logout", code: LoginError.generalError, userInfo: userInfo))
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            completionHandlerSessionLogout(nil)
        }
        task.resume()
    }
    
    static let sharedInstance = UdacityAuthentication()
    
}


