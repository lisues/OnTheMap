//
//  StudentDataSource.swift
//  OnTheMap
//
//  Created by Lisue She on 6/18/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation

class StudentDataSource {
    var studentData = [StudentData]()
    var pinStudent = StudentData()
    
    private init() {}
    
    static let sharedInstance = StudentDataSource()
}
