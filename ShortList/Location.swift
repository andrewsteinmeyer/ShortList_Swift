//
//  Location.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/26/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import ObjectMapper

class Location: Mappable {
  var name: String?
  var address: String?
  var latitude: Double?
  var longitude: Double?
  
  required init() {
  }
  
  required init?(_ map: Map) {
    mapping(map)
  }
  
  // Mappable
  func mapping(map: Map) {
    name        <- map["name"]
    address     <- map["address"]
    latitude    <- map["latitude"]
    longitude   <- map["longitude"]
  }
}
