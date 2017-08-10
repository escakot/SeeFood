//
//  ParseManager.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse

class ParseManager: NSObject {
  
  private override init() { }
  
  static let shared = ParseManager()
  
  var currentUser: PFUser?
  
  func userLogin(username:String, password:String, isLoginSuccessful: @escaping (Bool) -> Void )
  {
    PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
      if error != nil
      {
        print(error!.localizedDescription)
        isLoginSuccessful(false)
      } else {
        isLoginSuccessful(true)
      }
      
    }
  }
  
  
  func userSignUp(username:String, password:String, completionHandler: @escaping (String?) -> Void)
  {
    let newUser = PFUser()
    newUser.username = username
    newUser.password = password
    
    newUser.signUpInBackground { (bool, error) in
      if let error = error {
        print(error.localizedDescription)
        completionHandler(error.localizedDescription)
      } else {
        completionHandler(nil)
      }
    }
  }
  
  func queryRestaurantMenuItems(restaurantName:String, coordinates:CLLocationCoordinate2D, completionHandler: @escaping (Array<MenuItem>?) -> Void)
  {
    let innerQuery = Restaurant.query()
    innerQuery!.whereKey("name", contains: restaurantName)
    
    let query = MenuItem.query()
    query!.whereKey("restaurant", matchesQuery: innerQuery!)
    
    query!.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
      if error == nil
      {
        var tempArray:[MenuItem] = []
        if let objects = objects
        {
          for object in objects
          {
            tempArray.append(object as! MenuItem)
          }
          completionHandler(tempArray)
        }
      } else {
        print(error!.localizedDescription)
        completionHandler(nil)
      }
    })
    
  }

}
