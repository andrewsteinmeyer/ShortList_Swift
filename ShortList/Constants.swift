//
//  Constants.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/21/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Foundation

struct Constants {
  
  // Meteor
  struct Meteor {
    private static let Domain = "shortlist.meteor.com"
    
    static let RootUrl = "http://\(Domain)"
    static let DDPUrl = "ws://\(Domain)/websocket"
  }
  
}