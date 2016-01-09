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
    Meteor.callMethodWithName(Message.CreateVenue.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func delete(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteVenue.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  
  //MARK: - Stub methods to save locally before save to server
  
  func defineStubMethods() {
    
    Meteor.defineStubForMethodWithName(Message.CreateVenue.rawValue) {
      parameters in
      
      let name = parameters[0] as? String ?? nil
      let location = parameters[1] as? [String:AnyObject] ?? nil
      
      guard name != nil
        && location != nil
        else {
          return nil
      }
      
      let venue = NSEntityDescription.insertNewObjectForEntityForName(self.modelName, inManagedObjectContext: self.managedObjectContext) as! Venue
      venue.name = name
      venue.insertedOn = NSDate()
      venue.location = location
      
      // save locally
      self.saveManagedObjectContext()
      
      return nil
    }
    
  }
  
  
}
