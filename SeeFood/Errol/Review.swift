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
  @NSManaged var voting: Int
  @NSManaged var menuItem: MenuItem
  @NSManaged var restaurant: Restaurant
  
  // MARK: - Initializers
  convenience init(user: PFUser, image: PFFile, menuItem: MenuItem, restaurant: Restaurant)
  {
    self.init()
    self.user = user
    self.image = image
    self.voting = 0
    self.menuItem = menuItem
    self.restaurant = restaurant
  }
  
  func tags() -> PFRelation<Tag>
  {
    return self.relation(forKey: "tags") as! PFRelation<Tag>
  }
  
  static func parseClassName() -> String
  {
    return "Review"
  }
  
}
