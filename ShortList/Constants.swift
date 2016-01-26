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
    //private static let Domain = "10.0.0.3:3000"
    
    static let RootUrl = "http://\(Domain)"
    static let DDPUrl = "ws://\(Domain)/websocket"
  }
  
  // Google Maps
  struct GoogleMaps {
    static let ApiKey = "AIzaSyBk_737O6cJZiVdOlMhlaCWCyETfCcaQxc"
  }
  
}