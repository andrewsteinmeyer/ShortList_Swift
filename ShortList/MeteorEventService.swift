//
//  MeteorEventService.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/5/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


final class MeteorEventService {
  static let sharedInstance = MeteorEventService()
  
  private let modelName = "Event"
  
  private let managedObjectContext = Meteor.mainQueueManagedObjectContext
  
  private enum Message: String {
    case CreateEvent = "createEvent"
    case DeleteEvent = "deleteEvent"
    case InviteEvent = "inviteEvent"
    case SetInvitationResponse = "setInvitationResponse"
    case SendEventMessage = "sendEventMessage"
    case FindEventInfoById = "findEventInfoById"
    case skipContactInvite = "skipContactInvite"
  }
  
  init() {
    //defineStubMethods()
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
  
  func setInvitationResponse(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.SetInvitationResponse.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func sendEventMessage(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.SendEventMessage.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func findEventInfoById(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.FindEventInfoById.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func skipContactInvite(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.skipContactInvite.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  //MARK: - Stub methods to save locally before save to server
  
  func defineStubMethods() {
    
    Meteor.defineStubForMethodWithName(Message.CreateEvent.rawValue) {
      parameters in
      
      //TODO: Make sure this method is working.  MeteorContactService is not passing
      //      in all paramaters so its bailing on guard
      
      let name = parameters[0] as? String ?? nil
      let date = parameters[1] as? NSTimeInterval ?? nil
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
      event.list = list
      event.venue = venue
      event.location = location
      event.acceptedCount = 0
      
      // add date if present
      if let eventDate = date {
        event.date = eventDate
      }
      
      // add config if present
      if let config = eventConfiguration {
        event.eventConfiguration = config
      }
      
      // save locally
      self.saveManagedObjectContext()
      
      return nil
    }
    
    // TODO: Implement optimistic update on client for accepted count
    Meteor.defineStubForMethodWithName(Message.SetInvitationResponse.rawValue) {
      parameters in
      
      return nil
    }
    
  }
  
  
}