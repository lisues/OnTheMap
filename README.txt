###OnTheMap###


========================================================================
DESCRIPTION:
This app  populates a map that shows information posted by udacity students. The map will contain pins that show the location where the students have reported studying. By tapping on the pin users can see a URL for something the student finds interesting. The user will be able to add their own data by posting a string that can be geocoded to a location, and a URL.


Supported Formats


=========================================================================
BUILDS REQUIREMENTS:


Xcode 8.2.1,  IOS SDK 8.2 or better, 


=========================================================================
RUNTIME REQUIREMENTS:


iPhone, iPad, or iPod Touch running iOS 8.2.1 or better Xcode 8.2.1,  IOS SDK 8.2.1 or better, 


=========================================================================
PACKAGING LIST:


View/LoginViewController.swift
A UIViewController implements a root view controller to be the start point of the app .  Authenticating a user using over a network connection.


View/MapViewController.swift
It conforms with MKMapViewDelegate to populate the location of the udacity student locations. 


View/TableViewController.swift
It conforms with UITableViewController to populate the information of the udacity students in the table. It allows user to add and update their own data by posting a string that can be geocoded to a location, and a URL.


OnTheMapViewUtility.swift
A class that provides the APIs to support common functionalities and algorithm that are needed by multiple view controllers or classes.


Client/OnTheMapClient.swift
Throughout the app, there are several different type of network requests to the RESTful APIs from udacity and parse web services. They are well defined to make requests to the RESTful web services who provides REST APIs. 


Client/OnTheMapStudentData.swift
OnTheMapStudentData class provides all the functionalities needed for the network request to the web services and parse receiving data from the  web services.  


Client/OnTheMapAuthentication.swift
UdacityAuthentication class provides all the authentication network connections need.
 
Model/StudentDataSource.swift
Define StudentDataSource for the project.


 
=========================================================================
CHANGES FROM PREVIOUS VERSION:


1.0 First Release


=========================================================================
Copyright © 2017 All rights reserved