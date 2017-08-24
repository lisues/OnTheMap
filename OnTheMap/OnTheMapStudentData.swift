//
//  OnTheMapStudentData.swift
//  OnTheMap
//
//  Created by Lisue She on 5/29/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation

class OnTheMapStudentData: NSObject {
   
    func getStudentLocationData(withKey: String?, completionHandlerStudentLocations: @escaping (_ studentData:[StudentData]?) -> Void) {
        var parameters=[String: AnyObject]()
        let addHeaderField = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                              "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"]
        var method = Constants.OnTheMapApi.ApiParse
       
        if let key=withKey {
            let subMethod = "?where={\"uniqueKey\":\""+key+"\"}"
            if let escapedMethod=subMethod.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                method="\(method)\(escapedMethod)"
            }
        } else {
            parameters=["limit": 100 as AnyObject,
                        "order": "-updatedAt" as AnyObject]
        }
        
        OnTheMapClient.sharedInstance().taskRequest(.parseGet, method, addHeaderField:addHeaderField, setHeaderField:nil, parameters:parameters, jsonBody: nil) { (data, error) in
            if error != nil { // Handle error...
                completionHandlerStudentLocations(nil)
                return
            }
            
            OnTheMapClient.sharedInstance().performJSONSerialization(data: data) { (results) in
                if let results=results, let studentData=results["results"] as? [[String:AnyObject]] {
                    var studentLocations = [StudentData]()
                    for dictionary in studentData {
                        if let latitude=dictionary["latitude"] as? Double, let longitude=dictionary["longitude"] as? Double, let first=dictionary["firstName"] as? String, let last=dictionary["lastName"] as? String, let mediaURL=dictionary["mediaURL"] as? String,
                            let objectID=dictionary["objectId"] as? String,
                            let uniqueKey = dictionary["uniqueKey"] as? String {
                            var studentInfo=StudentData()
                            studentInfo.objectID = objectID
                            studentInfo.uniqueKey = uniqueKey
                            studentInfo.firstName = "\(first)"
                            studentInfo.lastName = "\(last)"
                            if let mapString = dictionary["mapString"] as? String {
                                studentInfo.mapString = mapString
                            }
                            studentInfo.latitude = latitude
                            studentInfo.longitude = longitude
                            studentInfo.mediaURL = mediaURL
                            studentLocations.append(studentInfo)
                        }
                    }
                    completionHandlerStudentLocations(studentLocations)
                    return
                } else {
                    completionHandlerStudentLocations(nil)
                    return
                }
            }
            return
        }
    }

    func postStudentLocationData(studentData: StudentData, completionHandlerPostStudentLocations: @escaping (_ error: NSError?) -> Void) {
        let parameters=[String: AnyObject]()
        let addHeaderField = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                              "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
                              "Content-Type": "application/json"]
        var method = Constants.OnTheMapApi.ApiParse
        var requestType = RequestType.parsePOST

        if let objectId=studentData.objectID {
                requestType = RequestType.parsePUT
                method = "\(Constants.OnTheMapApi.ApiParse)/\(objectId)"
        }

        let jsonBody = "{\"uniqueKey\": \"\(studentData.uniqueKey)\", \"firstName\": \"\(studentData.firstName)\", \"lastName\": \"\(studentData.lastName)\",\"mapString\": \"\(studentData.mapString)\", \"mediaURL\": \"\(studentData.mediaURL)\",\"latitude\": \(studentData.latitude), \"longitude\": \(studentData.longitude)}"
       
        let task = OnTheMapClient.sharedInstance().taskRequest(requestType, method, addHeaderField:addHeaderField, setHeaderField:nil, parameters:parameters, jsonBody: jsonBody) { (data, error) in
                if error != nil {
                    completionHandlerPostStudentLocations(error)
                    return
                } else {
                    completionHandlerPostStudentLocations(nil)
                    return
                }
        }
    }

   
    static let sharedInstance = OnTheMapStudentData()
}


