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
  
  private override init() {}
  
  static let shared = ParseManager()
  
  var currentUser: PFUser?
  
  func userLogin(username:String, password:String, isLoginSuccessful: @escaping (String?) -> Void )
  {
    PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
      if let error = error
      {
        print(error.localizedDescription)
        isLoginSuccessful(error.localizedDescription)
      } else {
        isLoginSuccessful(nil)
      }
      
    }
  }
  
  
  func userSignUp(username:String, password:String, email:String, completionHandler: @escaping (String?) -> Void)
  {
    let newUser = PFUser()
    newUser.username = username
    newUser.password = password
    newUser.email = email
    
    
    newUser.signUpInBackground { (bool, error) in
      if let error = error {
        print(error.localizedDescription)
        completionHandler(error.localizedDescription)
      } else {
        completionHandler(nil)
      }
    }
  }
  
  func queryMenuItemsFor(_ restaurant:Restaurant, completionHandler: @escaping (Array<MenuItem>?) -> Void)
  {
    let query = MenuItem.query()
    query!.whereKey("restaurant", equalTo: restaurant)
    
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
  
  func queryRestaurantWith(id:String, completionHandler: @escaping (Restaurant?) -> Void)
  {
    let query = Restaurant.query()
    query!.whereKey("id", contains: id)
//    query!.whereKey("coordinates", nearGeoPoint: coordinates)
    
    query?.getFirstObjectInBackground(block: { (object, error) in
      if error == nil
      {
        completionHandler(object as? Restaurant)
      } else {
        print(error!.localizedDescription)
        completionHandler(nil)
      }
    })
  }
  
  func createRestaurantProfileWith(id:String, name:String, completionHandler: @escaping (Bool, Restaurant?) -> Void)
  {
    let restaurant  = Restaurant(id:id, name:name)
    restaurant.saveInBackground { (success, error) in
      if (!success)
      {
        print(error!.localizedDescription)
        completionHandler(success, nil)
      } else {
        completionHandler(success, restaurant)
      }
    }
  }
  
  func createMenuItemFor(_ restaurant:Restaurant, title:String, completionHandler: @escaping (MenuItem) -> Void)
  {
    let menuItem = MenuItem(restaurant: restaurant, title: title)
    menuItem.saveInBackground { (success: Bool, error: Error?) in
      if success
      {
        restaurant.menu().add(menuItem)
        restaurant.saveInBackground()
        completionHandler(menuItem)
      } else {
        print(error!.localizedDescription)
      }
    }
  }
  
  func addReviewFor(_ menuItem:MenuItem, at restaurant:Restaurant, image:UIImage, completionHandler: @escaping () -> Void)
  {
    guard let user = PFUser.current(),
      let imageData = UIImagePNGRepresentation(image) else {
      return
    }
    let imageFile = PFFile(name: "image.png", data: imageData)
    let review = Review(user: user, image: imageFile!, menuItem: menuItem, restaurant: restaurant)
    review.saveInBackground { (success: Bool, error: Error?) in
      if success
      {
        menuItem.reviews().add(review)
        menuItem.saveInBackground()
        completionHandler()
      } else {
        print(error!.localizedDescription)
      }
    }
  }

}
