//
//  AppDelegate.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

import GoogleMaps
import GooglePlaces

let googleApiKey = "AIzaSyBiyh17wRHqgPgbdWW7tENfnFBwjMeT6ko"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(googleApiKey)
        
        return true
    }
}

