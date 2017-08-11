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
  
  func userLogin(username:String, password:String, isLoginSuccessful: @escaping (Bool) -> Void )
  {
    PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
      if error != nil
      {
        print(error!.localizedDescription)
        isLoginSuccessful(false)
      } else {
        self.currentUser = PFUser.current()
        isLoginSuccessful(true)
      }
      
    }
  }
  
  
  func userSignUp(username:String, password:String, completionHandler: @escaping (String?) -> Void)
  {
    let newUser = PFUser()
    newUser.username = username
    newUser.password = password
//    newUser.email = "email@example.com"
    
    
    newUser.signUpInBackground { (bool, error) in
      if let error = error {
        print(error.localizedDescription)
        completionHandler(error.localizedDescription)
      } else {
//        self.currentUser = PFUser.current()
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
  
  func queryRestaurantWith(name:String, coordinates:PFGeoPoint, completionHandler: @escaping (Restaurant?) -> Void)
  {
    let query = Restaurant.query()
    query!.whereKey("name", contains: name)
    query!.whereKey("coordinates", nearGeoPoint: coordinates)
    
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
  
  func createRestaurantProfileWith(id:String, name:String, coordinates:PFGeoPoint, completionHandler: @escaping (Bool) -> Void)
  {
    let restaurant  = Restaurant(id:id, name:name, coordinates:coordinates)
    restaurant.saveInBackground { (success, error) in
      if (!success)
      {
        print(error!.localizedDescription)
      }
      completionHandler(success)
    }
  }
  
  func createMenuItemFor(_ restaurant:Restaurant, title:String, price:Float, coordinates:CLLocationCoordinate2D, completionHandler: @escaping (MenuItem) -> Void)
  {
    let menuItem = MenuItem(restaurant: restaurant, title: title, price: price)
    menuItem.saveInBackground { (success: Bool, error: Error?) in
      if success
      {
        restaurant.menu().add(menuItem)
        restaurant.saveInBackground()
      } else {
        print(error!.localizedDescription)
      }
    }
  }
  
  func addReviewFor(_ menuItem:MenuItem, at restaurant:Restaurant, image:UIImage, comment:String?, rating:Int, completionHandler: @escaping () -> Void)
  {
    guard let user = PFUser.current(),
      let imageData = UIImagePNGRepresentation(image) else {
      return
    }
    let imageFile = PFFile(name: "image.png", data: imageData)
    let review = Review(user: user, image: imageFile!, comment:comment, rating: rating, menuItem: menuItem, restaurant: restaurant)
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
