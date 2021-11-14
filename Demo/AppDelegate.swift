//
//  AppDelegate.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

import GoogleMaps
import GooglePlaces
import Firebase

let googleApiKey = "AIzaSyBiyh17wRHqgPgbdWW7tENfnFBwjMeT6ko"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey(googleApiKey)
        
        return true
    }
}

