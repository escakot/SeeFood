//
//  ParseManager.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class ParseManager: NSObject {
  
  private override init() {}
  
  static let shared = ParseManager()
  
  var currentUser: PFUser?
  
  // MARK: - PFUser Methods
  
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
  
  func userResetPassword(username:String, email:String, completionHandler: @escaping (String?) -> Void)
  {
    if !email.isEmpty
    {
      PFUser.requestPasswordResetForEmail(inBackground: email, block: { (success, error) in
        if error == nil
        {
          completionHandler(nil)
        } else {
          print(error!.localizedDescription)
          completionHandler(error!.localizedDescription)
        }
      })
    }
    else
    {
      let query = PFUser.query()
      query?.whereKey("username", equalTo: username)
      
      query?.getFirstObjectInBackground(block: { (user, error) in
        if error == nil
        {
          let userEmail = (user as! PFUser).email!
          PFUser.requestPasswordResetForEmail(inBackground: userEmail, block: { (success, error) in
            if error == nil
            {
              completionHandler(nil)
            } else {
              print(error!.localizedDescription)
              completionHandler(error?.localizedDescription)
            }
          })
        }
      })
    }
  }
  
  func facebookLogin(completionHandler: @escaping (String?) -> Void)
  {
    let permissionsArray = ["public_profile", "email"]
    
    PFFacebookUtils.logInInBackground(withReadPermissions: permissionsArray) { (user:PFUser?, error:Error?) in
      if user == nil
      {
        completionHandler("Login failed")
        print("Facebook Login")
      } else if (user!.isNew) {
        completionHandler(nil)
        print("User signed up and logged in through Facebook")
      } else {
        completionHandler(nil)
        print("User logged in through Facebook")
      }
    }
  }
  
//  func facebookSignUp
  
  // MARK: - Query for PFObjects (Relational)
  
  func queryTagsFor(_ review:Review, completionHandler: @escaping (Array<Tag>?) -> Void)
  {
    let tagsQuery = review.tags().query()
    tagsQuery.findObjectsInBackground { (tags:[Tag]?, error:Error?) in
      if error == nil
      {
        completionHandler(tags)
      } else {
        print(error!.localizedDescription)
        completionHandler(nil)
      }
    }
  }
  
  func queryReviewFor(_ menuItem:MenuItem, completionHandler: @escaping (Array<Review>?) -> Void)
  {
    let reviewsQuery = menuItem.reviews().query()
    reviewsQuery.findObjectsInBackground { (reviews:[Review]?, error:Error?) in
      if error == nil
      {
        completionHandler(reviews)
      } else {
        print(error!.localizedDescription)
        completionHandler(nil)
      }
    }
  }
  
  func queryMenuItemsFor(_ restaurant:Restaurant, completionHandler: @escaping (Array<MenuItem>?) -> Void)
  {
    let menuItemsQuery = restaurant.menu().query()
    menuItemsQuery.findObjectsInBackground { (menu:[MenuItem]?, error:Error?) in
      if error == nil
      {
        completionHandler(menu!)
      } else {
        print(error!.localizedDescription)
        completionHandler(nil)
      }
    }
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
  
  
  // MARK: - Creating PFObjects (with Relations)
  
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
  
  func addReviewFor(_ menuItem:MenuItem, at restaurant:Restaurant, image:UIImage, completionHandler: @escaping (Review) -> Void)
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
        menuItem.saveInBackground(block: { (success, error) in
          if success { completionHandler(review) }
        })
      } else {
        print(error!.localizedDescription)
      }
    }
  }
  
  func addTagsFor(_ review:Review, tags:[Tag], completionHandler: @escaping () -> Void)
  {
    for tag in tags
    {
      tag.saveInBackground(block: { (success, error) in
        if error == nil
        {
          review.tags().add(tag)
          review.saveInBackground()
        } else {
          print(error!.localizedDescription)
        }
      })
    }
    completionHandler()
  }
  
}
