//
//  Review.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse

class Review: PFObject, PFSubclassing {
  
  // MARK: - Properties
  @NSManaged var user: PFUser
  @NSManaged var image: PFFile
  @NSManaged var comment: String?
  @NSManaged var rating: Int
  @NSManaged var voting: Int
  @NSManaged var menuItem: MenuItem
  @NSManaged var restaurant: Restaurant
  
  // MARK: - Initializers
  init(user: PFUser, image: PFFile, comment: String?, rating: Int, menuItem: MenuItem, restaurant: Restaurant)
  {
    super.init()
    self.user = user
    self.image = image
    self.comment = comment
    self.rating = rating
    self.menuItem = menuItem
    self.restaurant = restaurant
  }
  
  static func parseClassName() -> String
  {
    return "Review"
  }
  
}
