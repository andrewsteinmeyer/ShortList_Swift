//
//  MeteorListService.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/21/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//


final class MeteorListService {
  static let sharedInstance = MeteorListService()
  
  private let modelName = "List"
  
  private let managedObjectContext = Meteor.mainQueueManagedObjectContext
  
  private enum Message: String {
    case CreateList = "createList"
    case DeleteList = "deleteList"
    case RemoveContactFromList = "removeContactFromList"
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
    Meteor.callMethodWithName(Message.CreateList.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func delete(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteList.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func removeContactFromList(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.RemoveContactFromList.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  
  //MARK: - Stub methods to save locally before save to server
  
  func defineStubMethods() {
    
    Meteor.defineStubForMethodWithName(Message.CreateList.rawValue) {
      parameters in
      
      
      //TODO : contacts is not getting passed in with parameters[2] for some strange reason.
      //       see METMethodInvocationCoordinator
      
      let name = parameters[0] as? String ?? nil
      let security = parameters[1] as? String ?? nil
      let contacts = parameters[2] as? NSSet ?? nil
      
      guard name != nil
        && security != nil
        && contacts != nil
        else {
          return nil
      }
      
      let list = NSEntityDescription.insertNewObjectForEntityForName(self.modelName, inManagedObjectContext: self.managedObjectContext) as! List
      list.userId = AccountManager.defaultAccountManager.currentUserId
      list.name = name
      list.security = security
      list.contacts = contacts
      
      // save locally
      self.saveManagedObjectContext()
      
      return nil
    }
    
  }
  
  
}