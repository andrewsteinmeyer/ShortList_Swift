//
//  MeteorEventService.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/5/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Meteor

final class MeteorEventService {
  static let sharedInstance = MeteorEventService()
  
  private let modelName = "Event"
  
  private let managedObjectContext = Meteor.mainQueueManagedObjectContext
  
  private enum Message: String {
    case CreateEvent = "createEvent"
    case DeleteEvent = "deleteEvent"
    case InviteEvent = "inviteEvent"
  }
  
  init() {
    defineStubMethods()
  }
  
  // save locally to core data
  func saveManagedObjectContext() {
    var error: NSError?
    do {
      try managedObjectContext.save()
    } catch let error1 as NSError {
      error = error1
      print("Encountered error saving managed object context: \(error)")
    }
  }
  
  //MARK: - Meteor server calls
  
  func create(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.CreateEvent.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func delete(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteEvent.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func invite(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.InviteEvent.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  
  //MARK: - Stub methods to save locally before save to server
  
  func defineStubMethods() {
    
    Meteor.defineStubForMethodWithName(Message.CreateEvent.rawValue) {
      parameters in
      
      let name = parameters[0] as? String ?? nil
      let date = parameters[1] as? NSDate ?? nil
      let list = parameters[2] as? [String:AnyObject] ?? nil
      let venue = parameters[3] as? [String:AnyObject] ?? nil
      let location = parameters[4] as? [String:AnyObject] ?? nil
      let eventConfiguration = parameters[5] as? [String:AnyObject] ?? nil
      
      guard name != nil
        && list != nil
        && venue != nil
        && location != nil
        else {
          return nil
      }
      
      let event = NSEntityDescription.insertNewObjectForEntityForName(self.modelName, inManagedObjectContext: self.managedObjectContext) as! Event
      event.userId = AccountManager.defaultAccountManager.currentUserId
      event.name = name
      event.date = date
      event.list = list
      event.venue = venue
      event.location = location
      event.acceptedCount = 0
      
      // add config if present
      if let config = eventConfiguration {
        event.eventConfiguration = config
      }
      
      // save locally
      self.saveManagedObjectContext()
      
      return nil
    }
    
  }
  
  
}