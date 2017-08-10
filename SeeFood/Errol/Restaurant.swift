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
  @NSManaged var name: String
  @NSManaged var coordinates: PFGeoPoint
  @NSManaged var owner: PFUser
  @NSManaged var menu: PFRelation<MenuItem>
  
  // MARK: - Initializers
  init(name:String, coordinates:PFGeoPoint)
  {
    super.init()
    self.name = name
    self.coordinates = coordinates
  }
  
  static func parseClassName() -> String
  {
    return "Restaurant"
  }
  
}
