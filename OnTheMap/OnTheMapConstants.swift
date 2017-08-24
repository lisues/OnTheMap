//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Lisue She on 5/26/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation

struct LoginError {
    static let sucess=0
    static let generalError=1
    static let networkError=2
    static let authenticationError=3
}

enum RequestType {
    case udacityGET, udacityPOST, udacityDELETE, parseGet, parsePOST, parsePUT
}

enum HiddenElement {
    case udacityLogo, addressPrompt, linkPrompt
}

struct StudentData {
    
    var objectID: String?
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var latitude: Double
    var longitude: Double
    var mediaURL: String
    
    init () {
        uniqueKey = ""
        firstName = ""
        lastName = ""
        mapString = ""
        latitude = 0.0
        longitude = 0.0
        mediaURL = ""
    }
    
    init ( student: [String:AnyObject]? ) {
        self.init ()
        if let studentData = student {
            for (key, value) in studentData {
                if (key == "objectID") { objectID = value as? String }
                else if (key == "uniqueKey") { uniqueKey = value as! String }
                else if (key == "firstName") {  firstName = value as! String }
                else if (key == "lastName") { lastName = value as! String }
                else if (key == "mapString") { mapString = value as! String }
                else if (key == "latitude") { latitude = value as! Double }
                else if (key == "longitude") { longitude = value as! Double }
                else if (key == "mediaURL") { mediaURL = value as! String }
            }
        }
    }
 }

struct Constants {
    struct OnTheMapApi {
        static let UdacitySession = "https://www.udacity.com/api/session"
        static let UdacityUser = "https://www.udacity.com/api/users/"
        static let ApiParse = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let ApiParseMethod = "https://parse.udacity.com/parse/classes/StudentLocation?"
    }
}
