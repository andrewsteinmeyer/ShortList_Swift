//
//  EventConfiguration.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/8/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import ObjectMapper

class EventConfiguration: Mappable {
  var minimumGuests: String?
  var maximumGuests: String?
  var attendanceType: String?
  var status: String?
  var duration: String?
  
  enum Status: String {
    case On = "on"
    case Minimum = "minimum"
    case Tentative = "tentative"
    case Postponed = "postponed"
    case Cancelled = "cancelled"
  }
  
  enum AttendanceType: String {
    case Rank = "rank"
    case Random = "random"
    case FCFS = "fcfs"
    case NoLimit = "nolimit"
  }
  
  required init() {
  }
  
  required init?(_ map: Map) {
    mapping(map)
  }
  
  // Mappable
  func mapping(map: Map) {
    minimumGuests  <- map["minimumGuests"]
    maximumGuests  <- map["maximumGuests"]
    attendanceType <- map["attendanceType"]
    status         <- map["status"]
    duration       <- map["duration"]
  }
}