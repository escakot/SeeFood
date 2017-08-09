//
//  Restaurant.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse

class Restaurant: PFObject, PFSubclassing {

  // MARK: - Properties
  @NSManaged var owner: PFUser
  @NSManaged var menu: PFRelation<MenuItem>
  
  // MARK: - Initializers
  init(owner: PFUser, menu: PFRelation<MenuItem>)
  {
    super.init()
    self.owner = owner
    self.menu = menu
  }
  
  static func parseClassName() -> String
  {
    return "Restaurant"
  }
  
}
