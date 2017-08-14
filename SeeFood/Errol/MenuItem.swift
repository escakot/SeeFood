//
//  MenuItem.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse

class MenuItem: PFObject, PFSubclassing {

  // MARK: - Properties
  @NSManaged var restaurant: Restaurant
  @NSManaged var title: String
  
  // MARK: - Initializers
  convenience init(restaurant:Restaurant, title:String)
  {
    self.init()
    self.restaurant = restaurant
    self.title = title
  }
  
  func reviews() -> PFRelation<Review>
  {
    return self.relation(forKey: "reviews") as! PFRelation<Review>
  }
  
  static func parseClassName() -> String
  {
    return "MenuItem"
  }
  
}
