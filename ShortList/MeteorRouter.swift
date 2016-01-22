//
//  MeteorRouter.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/21/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Foundation

struct MeteorRouter {
  
  private static let baseURL = Constants.Meteor.RootUrl
  private static let token = AccountManager.defaultAccountManager.token
  
  private enum ResourcePath {
    case InvitationActivity(eventID: String)
    
    var description: String {
      switch self {
      case .InvitationActivity(let eventID): return "/event/\(eventID)/invitations/\(token)"
      }
    }
  }
  
  static func invitationActivityForEventID(eventID: String) -> String {
    return baseURL + ResourcePath.InvitationActivity(eventID: eventID).description
  }
}
