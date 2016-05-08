//
//  EventInvitation.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

struct EventInvitation {
  
  enum Status: String {
    case Accepted = "accepted"
    case Declined = "declined"
    case Timeout  = "timeout"
    case Active   = "active"
    case Bailout  = "bailout"
    case Skipped  = "skipped"
    case Maybe    = "maybe"
    case Capacity = "capacity"
    
    // NOTE: category order and enum order above must match
    //       not the best way, but will work until Swift has a way to count enums
    
    static let categories = [
      "accepted",
      "declined",
      "timeout",
      "active",
      "bailout",
      "skipped",
      "maybe",
      "capacity"
    ]
  }
  
}


