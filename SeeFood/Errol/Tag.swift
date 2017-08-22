//
//  Tag.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-22.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse

class Tag: PFObject, PFSubclassing {
  
  @NSManaged var title: String
  @NSManaged var centerX: CGFloat
  @NSManaged var centerY: CGFloat
  @NSManaged var review: Review

  static func parseClassName() -> String
  {
    return "Tag"
  }
}
