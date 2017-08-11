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
  @NSManaged var id: String
  @NSManaged var name: String
  @NSManaged var coordinates: PFGeoPoint
  @NSManaged var owner: PFUser
  
  // MARK: - Initializers
  convenience init(id:String, name:String, coordinates:PFGeoPoint)
  {
    self.init()
    self.id = id
    self.name = name
    self.coordinates = coordinates
  }
  
  func menu() -> PFRelation<MenuItem>
  {
    return self.relation(forKey: "menu") as! PFRelation<MenuItem>
  }
  
  static func parseClassName() -> String
  {
    return "Restaurant"
  }
  
}
