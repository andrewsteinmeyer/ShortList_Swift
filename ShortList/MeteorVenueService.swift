//
//  MeteorVenueService.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/27/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Meteor

final class MeteorVenueService {
  static let sharedInstance = MeteorVenueService()
  
  private let modelName = "Venue"
  
  private let managedObjectContext = Meteor.mainQueueManagedObjectContext
  
  private enum Message: String {
    case CreateVenue = "createVenue"
    case DeleteVenue = "deleteVenue"
  }
  
  init() {
    // TODO: create stub method for client local save before server save (see contact service)
    //defineStubMethods()
  }
  
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
    Meteor.callMethodWithName(Message.CreateVenue.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func delete(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteVenue.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  
  //MARK: - Stub Methods for Client
  
  func defineStubMethods() {
    
    // Create Venue stub
    // TODO: create stub method for client local save before server save (see contact service)
    Meteor.defineStubForMethodWithName(Message.CreateVenue.rawValue) {
      parameters in
      
      let name = parameters[0] as? String ?? nil
      let phone = parameters[1] as? String ?? nil
      let email = parameters[2] as? String ?? nil
      
      guard name != nil
        && phone != nil
        && email != nil
        else {
          return nil
      }
      
      let contact = NSEntityDescription.insertNewObjectForEntityForName(self.modelName, inManagedObjectContext: self.managedObjectContext) as! Contact
      contact.userId = AccountManager.defaultAccountManager.currentUserId
      contact.name = name
      contact.phone = phone
      contact.email = email
      
      self.saveManagedObjectContext()
      
      return nil
    }
    
  }
  
  
}
