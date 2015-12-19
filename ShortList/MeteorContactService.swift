//
//  MeteorContactService.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/17/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Meteor

final class MeteorContactService {
  static let sharedInstance = MeteorContactService()
  
  private enum Message: String {
    case ImportContacts = "importContacts"
    case CreateContact = "createContact"
    case DeleteContact = "deleteContact"
  }
  
  //MARK: Sign In and Out
  
  func create(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.CreateContact.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func delete(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteContact.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  func importContacts(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.ImportContacts.rawValue, parameters: parameters, completionHandler: completionHandler)
  }

}


