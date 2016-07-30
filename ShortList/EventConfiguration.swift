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
  var duration: String?
  
  private (set) var status: String?
  
  enum Status: Int {
    case On
    case Tentative
    case Minimum
    case Postponed
    case Cancelled
    
    var description: String {
      switch self {
      case .On:        return "on"
      case .Tentative: return "tentative"
      case .Minimum:   return "minimum"
      case .Postponed: return "postponed"
      case .Cancelled: return "cancelled"
      }
    }
  }
  
  // set default to "On"
  var currentStatus: Status = .On {
    didSet {
      self.status = currentStatus.description
    }
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