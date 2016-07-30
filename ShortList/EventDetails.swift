//
//  EventDetails.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/29/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


class EventDetails {
  
  enum InvitationTimer: Int {
    case ThirtyMinutes
    case OneHour
    case OneDay
    case OneWeek
    
    private var durationInSeconds: Int {
      switch self {
      case .ThirtyMinutes: return 1800
      case .OneHour:       return 3600
      case .OneDay:        return 86400
      case .OneWeek:       return 604800
      }
    }
  }
  
  enum EventStartTime: Int {
    case Now
    case OneHour
    case Later
  }
  
  var title: String?
  var list: List?
  var date: NSDate?
  var location: Location?
  var configuration: EventConfiguration
  var invitationDuration: InvitationTimer
  
  var venue: Venue? {
    didSet {
      guard venue != nil else { return }
      
      // extract venue location
      if let venueLocation = venue?.valueForKey("location") {
        let JSONLocation = JSON(venueLocation)
        
        let location = Location()
        location.name = JSONLocation["name"].string ?? ""
        location.address = JSONLocation["address"].string ?? ""
        location.latitude = JSONLocation["latitude"].double ?? 0.0
        location.longitude = JSONLocation["longitude"].double ?? 0.0
        
        self.location = location
      }
    }
  }
  
  // MARK: - Initialization
  
  init() {
    // set default to one hour
    self.invitationDuration = .OneHour
    self.configuration      = EventConfiguration()
  }
  
  
  
  
}