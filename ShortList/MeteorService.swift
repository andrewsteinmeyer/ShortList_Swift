//
//  MeteorService.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Meteor

struct MeteorService {
  
  private enum Message: String {
    case CreateList = "createList"
    case DeleteList = "deleteList"
    case UpdateListContacts = "updateListContacts"
    case CreateVenue = "createVenue"
    case DeleteVenue = "deleteVenue"
    case ImportContacts = "importContacts"
    case CreateContact = "createContact"
    case DeleteContact = "deleteContact"
  }
  
  //MARK: Lists
  
  static func createList(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.CreateList.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  static func deleteList(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteList.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  static func updateListContacts(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.UpdateListContacts.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  //MARK: Venues
  
  static func createVenue(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.CreateVenue.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  static func deleteVenue(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteVenue.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  //MARK: Contacts
  
  static func importContacts(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.ImportContacts.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  static func createContact(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.CreateContact.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  static func deleteContact(parameters: [AnyObject]?, completionHandler: METMethodCompletionHandler?) {
    Meteor.callMethodWithName(Message.DeleteContact.rawValue, parameters: parameters, completionHandler: completionHandler)
  }
  
  

}

