//
//  AppDelegate.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-08.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit

import Parse
import ParseFacebookUtilsV4
import GoogleMaps
import GooglePlaces
import FBSDKCoreKit
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  let googlePlacesAPIkey = "AIzaSyCZMN6Ovp2sJZDnAG5eFh1jlyHTIg4aju8"

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    IQKeyboardManager.shared().isEnabled = true
    
    //Parse Setup
    Restaurant.registerSubclass()
    MenuItem.registerSubclass()
    Review.registerSubclass()
    Tag.registerSubclass()
    
    let configuration = ParseClientConfiguration {
      $0.applicationId = "k28agL9Gsu2lP9KAgnwo238aAj7Vmjg5iB"
      $0.server = "https://seefoods.herokuapp.com/parse"
    }
    Parse.initialize(with: configuration)
    
    GMSServices.provideAPIKey("AIzaSyDnaWnMHeK5LNQ4rXlHUGZ5RR-nA79oUq8")
    GMSPlacesClient.provideAPIKey(googlePlacesAPIkey)

    //Facebook Setup
    PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    FBSDKAppEvents.activateApp()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    
    return handled
  }


}

